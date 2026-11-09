# Publishing your Retail BI case study and portfolio update

This package contains **two different GitHub upload destinations**. Do not upload the whole package into either repository.

## 1. Create the project repository FIRST

1. In your GitHub account, create a **public** repository named `retail-sales-business-intelligence` (or choose a different name and update the website link accordingly).
2. Open the folder `retail-sales-business-intelligence/` from this package.
3. Upload its `README.md`, `sql/` and `docs/` contents to the **root of that new repository**, preserving the folders.
4. Confirm your GitHub project case study is visible at:
   `https://github.com/FelixAkanno/retail-sales-business-intelligence`
5. Open the link to Tableau Public in the README and verify that it lands on Sales Overview.

**Note:** The SQL is portfolio documentation for a BigQuery implementation that has **not** been run in Google Cloud; the project's ETL was validated locally. The SQL file's original cloud project ID has been replaced with the placeholder `your-project-id`.

## 2. Update your EXISTING GitHub Pages website

1. Open the GitHub repository that currently hosts `https://felixakanno.github.io/`.
2. Make a backup or commit of your current root `index.html`.
3. Replace **only** that repository's root `index.html` with `website/index.html` from this package.
4. Preserve your existing `assets/` directory, `images/car_1.jpg`, and other website files. This HTML still relies on your original HTML5 UP theme assets.
5. Commit the change and refresh your website once GitHub Pages has deployed it.
6. Test the **View GitHub Case Study**, **Explore Live Dashboards**, automotive project, LinkedIn, and GitHub links on desktop and mobile.

The replacement HTML deliberately does **not** require any new image, JavaScript, or stylesheet file. Its new feature-card styles are included inline.

## 3. Changes made to the original HTML

- Featured the retail business intelligence project, KPI highlights, skill tags, and two links.
- Preserved the existing automotive project as a secondary project card.
- Added a concise About Me section, linked in the navigation.
- Updated the homepage description to include Tableau and fixed the title typo.
- Changed the contact email to a working `mailto:` link.
- Replaced the full street address with **Calgary, Alberta, Canada** and removed the placeholder `(000) 000-0000` phone number for professional presentation and privacy. You can reverse these two choices if desired.
- Preserved HTML5 UP license and theme attribution.

## 4. Optional improvements after publishing

- Capture a clean screenshot of **Sales Overview** and add it to the project repository under `screenshots/`; reference it from the README.
- Feature the GitHub case study and the live Tableau link on LinkedIn.
- Inspect your Tableau Public workbook in a private browser window and confirm its tab navigation, filters, and drill-through.
- If the GitHub repository name changes, update both the HTML link and the LinkedIn destination.

## 5. Links used

- Portfolio website: https://felixakanno.github.io/
- Intended project repository: https://github.com/FelixAkanno/retail-sales-business-intelligence
- Tableau Public: https://public.tableau.com/app/profile/felix.akanno/viz/NationalRetailChainEnterpriseBICapstone/SalesOverview

No GitHub repository or website was modified automatically by this package.
