# Building AI Agents for Production

**Think Outside The Loop · GONG/LOOP | BAND** · 22 בנובמבר, Gong HQ

בפאנל: Nadav Hoze (Gong, מנחה), Ariel Shulman (Nvidia), Gilad Shoham (Bit), Raz Berman Gold (Overcut.ai), Vlad Luzin (Band).

## דף ההצבעה של הקהל

https://nadavhdev.github.io/ai-agents-panel/

הדף שנפתח מה-QR במערכה השלישית. הקהל בוחר על איזה נושא נדבר עכשיו, בהצבעות של 20 שניות.

- `index.html`, `config.js`, `logo.png`: דף ההצבעה, שמתפרסם ב-GitHub Pages.
- ההצבעות נשמרות ב-Supabase. ב-`config.js` יש רק את ה-publishable key, שבנוי להיות ציבורי. הגישה הישירה לטבלאות חסומה, וכל פעולה עוברת דרך פונקציות. רק הלוח של המנחה, עם מפתח המנחה, יכול לפתוח ולסגור הצבעה.

## materials

| קובץ | מה זה |
|---|---|
| `AI-Agents-Panel-Live.html` | המצגת החיה להנחיה: הגרלות במערכות 1-2, הצבעת הקהל במערכה 3 ושקף Key Takeaways. אין בה את מפתח המנחה. בפעם הראשונה לוחצים K ומזינים אותו, והוא נשמר במחשב. |
| `AI-Agents-Panel-Gong.pptx`, `AI-Agents-Panel-Gong.pdf` | אותה מצגת בתבנית של Gong, בלי האינטראקציה. |
| `AI-Agents-Panel-Topic-Cards.pdf` | כרטיסי הנושאים של כל המערכות. |
| `AI-Agents-Panel-Topics.docx`, `AI-Agents-Panel-Topics.pdf` | מסמך הנושאים לשיחה. |
| `AI-Agents-Panel-Topic-Preferences.xlsx`, `AI-Agents-Panel-Topics-Selection.xlsx` | הטבלאות לבחירת הנושאים. |
| `supabase-setup.template.sql` | הקמת ההצבעה ב-Supabase. לפני ההרצה מחליפים את `__HOST_KEY__` במפתח המנחה. |

## מקשים במצגת החיה

| מקש | מה הוא עושה |
|---|---|
| Enter | במערכות 1-2: הגרלה. במערכה 3: פותחים הצבעה, סוגרים אותה מוקדם, חושפים את הנושא. בשקף האחרון: הזרקור עובר מאחד לשני |
| S | דילוג על הנושא הבא (מערכות 1-2) |
| לחיצה על כרטיס או על נושא בלוח | עוברים אליו ישר |
| חץ ימינה או רווח, חץ שמאלה | השקף הבא, השקף הקודם |
| F | מסך מלא |
| K | הזנת מפתח המנחה |
| V | שינוי הכתובת שב-QR |
