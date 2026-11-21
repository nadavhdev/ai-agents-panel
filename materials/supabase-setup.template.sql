-- Building AI Agents for Production: the audience vote for act 3 (20-second rounds)
-- Run in Supabase: SQL Editor > New query > paste everything > Run.
-- Safe to run again, also over the first version of this script.
-- The copy with the real host key stays private: only the presenter's board uses that key.

create table if not exists public.panel_state (
  id smallint primary key default 1 check (id = 1),
  round integer not null default 0,
  is_open boolean not null default false,
  options integer[] not null default '{}',
  updated_at timestamptz not null default now()
);
alter table public.panel_state add column if not exists ends_at timestamptz;
insert into public.panel_state (id) values (1) on conflict (id) do nothing;

create table if not exists public.panel_votes (
  round integer not null,
  device text not null,
  choice integer not null,
  voted_at timestamptz not null default now(),
  primary key (round, device)
);

-- No direct table access from the browser: everything goes through the functions below.
alter table public.panel_state enable row level security;
alter table public.panel_votes enable row level security;
revoke all on table public.panel_state, public.panel_votes from anon, authenticated;

-- Audience: the current round, whether it is still open, the topics on the board and the time left.
create or replace function public.panel_get_state()
returns json
language sql
stable
security definer
set search_path = public
as $$
  select json_build_object(
    'round', s.round,
    'open', s.is_open and (s.ends_at is null or now() < s.ends_at),
    'options', s.options,
    'remaining', case when s.is_open and s.ends_at is not null
                      then greatest(0, extract(epoch from (s.ends_at - now()))) end,
    'seconds', case when s.ends_at is not null
                    then (extract(epoch from (s.ends_at - s.updated_at)))::integer end)
  from panel_state s where s.id = 1;
$$;

-- Audience: vote in the open round, until its time is up (voting again replaces the earlier vote).
create or replace function public.panel_vote(p_device text, p_choice integer)
returns json
language plpgsql
security definer
set search_path = public
as $$
declare
  s panel_state;
begin
  select * into s from panel_state where id = 1;
  if s.id is null or not s.is_open or (s.ends_at is not null and now() >= s.ends_at) then
    return json_build_object('ok', false, 'reason', 'closed');
  end if;
  if p_choice is null or not (p_choice = any (s.options)) then
    return json_build_object('ok', false, 'reason', 'option');
  end if;
  if p_device is null or char_length(p_device) not between 8 and 64 then
    return json_build_object('ok', false, 'reason', 'device');
  end if;
  insert into panel_votes (round, device, choice)
  values (s.round, p_device, p_choice)
  on conflict (round, device) do update set choice = excluded.choice, voted_at = now();
  return json_build_object('ok', true, 'round', s.round, 'choice', p_choice);
end;
$$;

-- Board: live vote counts for one round, as {"choice": votes}.
create or replace function public.panel_tally(p_round integer)
returns json
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(json_object_agg(choice, n), '{}'::json)
  from (select choice, count(*) as n from panel_votes where round = p_round group by choice) t;
$$;

-- Board only (needs the host key): open a round on the remaining topics for p_seconds, or close voting.
drop function if exists public.panel_host(text, integer, boolean, integer[]);
create or replace function public.panel_host(p_key text, p_round integer, p_open boolean, p_options integer[],
                                             p_seconds integer default null)
returns json
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_key is distinct from '__HOST_KEY__' then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  if p_seconds is not null and (p_seconds < 5 or p_seconds > 600) then
    raise exception 'seconds must be between 5 and 600' using errcode = '22023';
  end if;
  update panel_state
     set round = p_round,
         is_open = p_open,
         options = coalesce(p_options, '{}'),
         ends_at = case when p_open and p_seconds is not null then now() + make_interval(secs => p_seconds) end,
         updated_at = now()
   where id = 1;
  return panel_get_state();
end;
$$;

revoke all on function public.panel_get_state() from public;
revoke all on function public.panel_vote(text, integer) from public;
revoke all on function public.panel_tally(integer) from public;
revoke all on function public.panel_host(text, integer, boolean, integer[], integer) from public;
grant execute on function public.panel_get_state() to anon, authenticated;
grant execute on function public.panel_vote(text, integer) to anon, authenticated;
grant execute on function public.panel_tally(integer) to anon, authenticated;
grant execute on function public.panel_host(text, integer, boolean, integer[], integer) to anon, authenticated;

notify pgrst, 'reload schema';
