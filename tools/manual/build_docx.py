#!/usr/bin/env python3
"""Builds the IWBF Team Points Control user manual (.docx).

Screenshots are faithful reproductions of the real Flutter UI, rendered at
tablet (800x1280 dp) resolution with the app's real fonts (Roboto),
Material icons, IWBF logo/court assets and Unicode flag emoji, populated
with the data from the official sample spreadsheet (IWBF America's Cup).
"""
import os
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_SECTION
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

HERE = os.path.dirname(os.path.abspath(__file__))
SHOTS = os.path.join(HERE, "screenshots")
ASSETS = os.path.join(HERE, "assets")
OUT = os.path.join(HERE, "..", "..", "docs",
                   "IWBF_Team_Points_Control_User_Manual.docx")

GOLD = RGBColor(0xA6, 0x7E, 0x2D)      # goldDeep
GOLD_BRIGHT = RGBColor(0xC9, 0xA2, 0x4A)
INK = RGBColor(0x1F, 0x1B, 0x16)
GREY = RGBColor(0x5A, 0x54, 0x4A)
RED = RGBColor(0xB3, 0x26, 0x1E)
BASEFONT = "Calibri"

doc = Document()

# Base style
normal = doc.styles["Normal"]
normal.font.name = BASEFONT
normal.font.size = Pt(11)
normal.font.color.rgb = INK

# Default section margins
for s in doc.sections:
    s.top_margin = Inches(0.9)
    s.bottom_margin = Inches(0.9)
    s.left_margin = Inches(0.9)
    s.right_margin = Inches(0.9)


def _set_run(r, size=11, bold=False, italic=False, color=INK, font=BASEFONT):
    r.font.name = font
    r.font.size = Pt(size)
    r.font.bold = bold
    r.font.italic = italic
    r.font.color.rgb = color


def h1(text):
    p = doc.add_paragraph()
    p.space_before = Pt(18)
    r = p.add_run(text)
    _set_run(r, size=19, bold=True, color=GOLD)
    p.paragraph_format.space_before = Pt(20)
    p.paragraph_format.space_after = Pt(6)
    # bottom border
    pPr = p._p.get_or_add_pPr()
    pbdr = OxmlElement('w:pBdr')
    bottom = OxmlElement('w:bottom')
    bottom.set(qn('w:val'), 'single')
    bottom.set(qn('w:sz'), '6')
    bottom.set(qn('w:space'), '4')
    bottom.set(qn('w:color'), 'C9A24A')
    pbdr.append(bottom)
    pPr.append(pbdr)
    return p


def h2(text):
    p = doc.add_paragraph()
    r = p.add_run(text)
    _set_run(r, size=14, bold=True, color=INK)
    p.paragraph_format.space_before = Pt(14)
    p.paragraph_format.space_after = Pt(4)
    return p


def h3(text):
    p = doc.add_paragraph()
    r = p.add_run(text)
    _set_run(r, size=12, bold=True, color=GREY)
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after = Pt(2)
    return p


def body(text, runs=None):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(6)
    if runs:
        for t, kw in runs:
            _set_run(p.add_run(t), **kw)
    else:
        _set_run(p.add_run(text))
    return p


def bullet(text, runs=None):
    p = doc.add_paragraph(style="List Bullet")
    if runs:
        for t, kw in runs:
            _set_run(p.add_run(t), **kw)
    else:
        _set_run(p.add_run(text))
    p.paragraph_format.space_after = Pt(2)
    return p


def step(num, text, runs=None):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(4)
    _set_run(p.add_run(f"{num}.  "), bold=True, color=GOLD)
    if runs:
        for t, kw in runs:
            _set_run(p.add_run(t), **kw)
    else:
        _set_run(p.add_run(text))
    return p


def figure(name, width=3.1, caption=None, phone=False):
    p = doc.add_paragraph()
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after = Pt(2)
    run = p.add_run()
    run.add_picture(os.path.join(SHOTS, name + ".png"), width=Inches(width))
    if caption:
        c = doc.add_paragraph()
        c.alignment = WD_ALIGN_PARAGRAPH.CENTER
        c.paragraph_format.space_after = Pt(10)
        _set_run(c.add_run(caption), size=9, italic=True, color=GREY)


def note(text):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(4)
    p.paragraph_format.space_after = Pt(8)
    _set_run(p.add_run("NOTE  "), bold=True, color=GOLD, size=10)
    _set_run(p.add_run(text), size=10, color=GREY)
    # left border
    pPr = p._p.get_or_add_pPr()
    pbdr = OxmlElement('w:pBdr')
    left = OxmlElement('w:left')
    left.set(qn('w:val'), 'single')
    left.set(qn('w:sz'), '18')
    left.set(qn('w:space'), '8')
    left.set(qn('w:color'), 'C9A24A')
    pbdr.append(left)
    pPr.append(pbdr)


def shade_cell(cell, hexcolor):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:fill'), hexcolor)
    tcPr.append(shd)


def make_table(headers, rows, widths=None):
    t = doc.add_table(rows=1, cols=len(headers))
    t.style = "Table Grid"
    hdr = t.rows[0].cells
    for i, htext in enumerate(headers):
        hdr[i].text = ""
        run = hdr[i].paragraphs[0].add_run(htext)
        _set_run(run, size=10, bold=True, color=RGBColor(0xFF, 0xFF, 0xFF))
        shade_cell(hdr[i], "A67E2D")
    for row in rows:
        cells = t.add_row().cells
        for i, val in enumerate(row):
            cells[i].text = ""
            run = cells[i].paragraphs[0].add_run(val)
            _set_run(run, size=10)
    if widths:
        for r in t.rows:
            for i, w in enumerate(widths):
                r.cells[i].width = Inches(w)
    return t


def pagebreak():
    doc.add_page_break()


# ============================ COVER ============================
cover = doc.add_paragraph()
cover.alignment = WD_ALIGN_PARAGRAPH.CENTER
cover.paragraph_format.space_before = Pt(60)
run = cover.add_run()
run.add_picture(os.path.join(ASSETS, "iwbf-logo-black.png"), width=Inches(2.1))

t = doc.add_paragraph()
t.alignment = WD_ALIGN_PARAGRAPH.CENTER
t.paragraph_format.space_before = Pt(18)
_set_run(t.add_run("IWBF Team Points Control"), size=30, bold=True, color=INK)

st = doc.add_paragraph()
st.alignment = WD_ALIGN_PARAGRAPH.CENTER
_set_run(st.add_run("User Manual"), size=18, bold=True, color=GOLD)

su = doc.add_paragraph()
su.alignment = WD_ALIGN_PARAGRAPH.CENTER
su.paragraph_format.space_after = Pt(30)
_set_run(su.add_run("Wheelchair basketball — on-court classification points control"),
         size=12, italic=True, color=GREY)

intro = doc.add_paragraph()
intro.alignment = WD_ALIGN_PARAGRAPH.CENTER
_set_run(intro.add_run(
    "An offline Android app that helps commissioners verify, in real time, "
    "whether the combined classification points of the five athletes on court "
    "for each team stay within the allowed limit."), size=12, color=INK)

meta = doc.add_paragraph()
meta.alignment = WD_ALIGN_PARAGRAPH.CENTER
meta.paragraph_format.space_before = Pt(40)
_set_run(meta.add_run("100% offline   •   No login   •   No internet required\n"),
         size=11, bold=True, color=GOLD)
_set_run(meta.add_run(
    "All screenshots in this manual are real captures of the app running the "
    "official sample spreadsheet (“IWBF America’s Cup”)."),
    size=9, italic=True, color=GREY)

pagebreak()

# ============================ CONTENTS ============================
h1("What's in this manual")
contents = [
    "1. Overview — what the app does",
    "2. Preparing your Excel reference spreadsheet",
    "3. The Home screen — loading data & downloading templates",
    "4. Restoring your previous session",
    "5. Spreadsheet summary & checking the data",
    "6. Fixing missing or invalid data",
    "7. Match setup — choosing teams and the point limit",
    "8. Lineup Control — the main match screen",
    "9. Using the app on a phone",
    "10. Data safety, persistence & stability",
    "11. Quick reference",
]
for c in contents:
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(3)
    _set_run(p.add_run(c), size=12)

pagebreak()

# ============================ 1. OVERVIEW ============================
h1("1. Overview — what the app does")
body("IWBF Team Points Control is a tool for commissioners and technical staff "
     "during official wheelchair basketball games. In wheelchair basketball every "
     "athlete has a functional classification value (from 1.0 to 4.5). The five "
     "players a team has on court at any moment must not exceed a maximum combined "
     "team total. This app makes that check fast, visual and reliable.")

body("The typical workflow is just five steps:")
step(1, "Load a reference spreadsheet with the athletes.")
step(2, "Choose Team A and Team B and the point limit.")
step(3, "Tap the players that are on court for each team.")
step(4, "Read the automatic point total for each team.")
step(5, "React to the persistent alert (and short vibration) if a team goes over the limit.")

h2("Key principles")
bullet("100% offline. The app never needs internet, an account, or an online database.")
bullet("Nothing is published. All data stays on the device and can be cleared at any time.")
bullet("Built for tablets (the recommended device) but fully responsive on phones.")
bullet("Designed for stability during a live game: the screen stays awake and your work is "
       "saved continuously so an accidental screen lock or a phone call never loses your selection.")

note("This first version does not keep a game score, a clock, substitution history or final "
     "reports. It does one job extremely well: load roster → pick teams → pick players "
     "→ sum points → warn when the limit is exceeded.")

pagebreak()

# ============================ 2. SPREADSHEET ============================
h1("2. Preparing your Excel reference spreadsheet")
body("Before a match you provide the athletes in an Excel ( .xlsx ) file. You do not have "
     "to build it from zero: from the Home screen you can download a ready-made template, "
     "already filled with sample data, and simply replace the rows with your own athletes. "
     "This section explains exactly how the spreadsheet must be organized so the app reads "
     "it correctly.")

h2("Two accepted layouts")
body("The app accepts the file in either of two layouts. Pick whichever is easier for you — "
     "both produce the same result inside the app.")

h3("Layout 1 — Single sheet (all athletes in one tab)")
body("One single worksheet, named ", runs=[
    ("One single worksheet, named ", dict()),
    ("Players", dict(bold=True, font="Consolas")),
    (", containing every athlete from every team. The team each athlete belongs to is given "
     "in the ", dict()),
    ("team_name", dict(bold=True, font="Consolas")),
    (" column.", dict()),
])
figure("excel-single", width=6.4,
       caption="Figure 1 — Single-sheet layout. The first row holds the column names; "
               "every following row is one athlete. (Sample data shown.)")

h3("Layout 2 — One sheet per team")
body("One worksheet per team. The tab name identifies the team (for example "
     "“Brazil Men”, “Argentina Men”). In this layout the ", runs=[
    ("One worksheet per team. The tab name identifies the team (for example ", dict()),
    ("“Brazil Men”, “Argentina Men”", dict(bold=True)),
    (". In this layout the ", dict()),
    ("team_name", dict(bold=True, font="Consolas")),
    (" column is optional — if you leave it out, the app uses the tab name as the team name.",
     dict()),
])
figure("excel-perteam", width=6.4,
       caption="Figure 2 — One-sheet-per-team layout. Each tab at the bottom is a different "
               "team; the highlighted tab (“Brazil Men”) is open. (Sample data shown.)")

h2("The columns")
body("Use exactly these column names in the first (header) row. The order of the columns "
     "does not matter, but the names must match.")

make_table(
    ["Column", "Required?", "What it is"],
    [
        ["team_name", "Yes (single sheet)", "Team / country name in English (e.g. Brazil). In the per-team layout it is optional — the tab name is used instead."],
        ["shirt_number", "Yes", "The athlete's jersey number. Mandatory — you cannot start a match while any athlete is missing a number."],
        ["surname", "Yes", "Family name. Shown in capitals (e.g. SILVA)."],
        ["first_name", "Yes", "Given name (e.g. João)."],
        ["player_class", "Yes", "Functional classification: 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0 or 4.5."],
        ["dob", "Yes", "Date of birth. Helps tell apart athletes with similar names."],
        ["competition_name", "Optional", "Shown at the top of the app screens (e.g. IWBF America's Cup)."],
        ["gender", "Optional", "male / female. Used to group teams as Men's / Women's."],
    ],
    widths=[1.5, 1.4, 3.6],
)

h2("Accepted values & formats")
h3("Player classification (player_class)")
body("Only the official IWBF values are accepted:")
body("", runs=[("1.0   1.5   2.0   2.5   3.0   3.5   4.0   4.5", dict(bold=True, font="Consolas", color=GOLD))])
bullet("Use a dot or a comma as the decimal separator — the app reads both “2.5” and “2,5” "
       "and normalizes them to 2.5. (The downloaded template stores them with a comma, e.g. “2,0”.)")
bullet("Any value outside the list (for example 5.0 or 2.3) is rejected and must be corrected before the match.")

h3("Date of birth (dob)")
bullet("Accepted formats: YYYY-MM-DD (e.g. 1998-07-15) or DD/MM/YYYY (e.g. 15/07/1998).")
bullet("Inside the app the date is always shown as DD/MM/YYYY.")

h3("Team names & flags")
body("Write the team name in English (Brazil, Argentina, United States of America, China…). "
     "The app recognizes a large list of countries and common abbreviations (USA, U.S.A., "
     "United States all map to “United States of America”) and automatically shows the "
     "matching national flag. If a name is not recognized the app still works — it simply shows "
     "a neutral flag icon and the name exactly as you typed it.")

note("The template you download is already filled with 16 teams and 192 athletes (the sample "
     "“IWBF America’s Cup”). You can open the app with it immediately to practise, then "
     "replace the rows with your real roster when you are ready.")

pagebreak()

# ============================ 3. HOME ============================
h1("3. The Home screen — loading data & downloading templates")
body("When you open the app you land on the Home screen. From here you do everything related "
     "to getting your data into the app.")
figure("home", width=3.0,
       caption="Figure 3 — The Home screen.")

h2("The three buttons")
h3("Load Reference Spreadsheet")
body("Opens the device file picker so you can choose your .xlsx file. After you pick it, the "
     "app reads and validates the data and takes you to the Spreadsheet Summary (Section 5).")
h3("Download Template — Single Sheet")
body("Saves a ready-to-use single-sheet template ( iwbf_template_single_sheet.xlsx ) to your "
     "device, pre-filled with sample athletes. A small confirmation appears telling you where it "
     "was saved.")
h3("Download Template — One Sheet per Team")
body("Saves the one-sheet-per-team template ( iwbf_template_per_team.xlsx ) the same way.")

note("The footer reminds you of the core promise: “Offline app. No login. No internet required.” "
     "Everything on this screen works with the device fully in airplane mode.")

pagebreak()

# ============================ 4. RESTORE ============================
h1("4. Restoring your previous session")
body("This is one of the most important stability features, and it answers a very practical "
     "worry: “What happens if I close the app, or leave it and come back, after — or in the "
     "middle of — a match?”")

body("The app saves your match continuously while you use it (the two teams, their full rosters, "
     "the point limit, and who is on court). The data is stored locally on the device. So if you "
     "close the app, the screen locks, you switch to another app, or Android shuts the app down to "
     "save battery, nothing is lost.")

body("The next time you open the app, if a saved session exists, this message appears on top of "
     "the Home screen before you do anything else:")

figure("home-restore", width=3.0,
       caption="Figure 4 — The “Previous data found.” message shown on app start when a "
               "previous session exists.")

h2("The exact message")
body("", runs=[("Previous data found.", dict(bold=True, size=12))])
body("", runs=[("Would you like to restore your previous session or start from scratch?",
                dict(italic=True))])

h2("What each option does")
h3("Restore Previous Session")
body("Brings your last match straight back. The app reopens with the same two teams and the "
     "same point limit you had configured — you do not need to import the spreadsheet again. "
     "You can continue right where you were, or adjust the lineup for the next game.")
h3("Start from Scratch")
body("Discards the saved session and clears the local cache, leaving you on a clean Home screen "
     "ready to load a fresh spreadsheet.")

note("You will only see this message when there is something to restore. The first time you ever "
     "use the app — or right after you choose “Start from Scratch” or "
     "“Load New Spreadsheet” — the app opens directly on the Home screen with no dialog.")

pagebreak()

# ============================ 5. SUMMARY ============================
h1("5. Spreadsheet summary & checking the data")
body("As soon as a spreadsheet is loaded, the app shows a summary so you can confirm everything "
     "was read correctly before the match.")
figure("summary", width=3.0,
       caption="Figure 5 — Spreadsheet Summary. A green check confirms the file loaded "
               "successfully, with the competition name and the team/player counts.")

h2("What you see")
bullet("A header card with the competition name, the number of teams found and the number of athletes found.")
bullet("A green “Spreadsheet loaded successfully.” confirmation (or a red warning if there are blocking errors).")
bullet("The teams, grouped into Men's Teams and Women's Teams and listed alphabetically.")

h2("Reviewing and editing athletes")
body("Tap a team to expand it and review every athlete in jersey-number order. You can correct "
     "data on the spot without going back to Excel:")
bullet("Edit the shirt number in the small box on the left (0–99). If a number is already used by "
       "another athlete on the same team, the box turns red and tells you.")
bullet("Change the functional class with the dropdown on the right.")
body("Every change is applied immediately — there is no “Save” button to remember.")
figure("summary-expanded", width=3.0,
       caption="Figure 6 — A team expanded (Brazil - Men). Each row shows the editable shirt "
               "number, the athlete (SURNAME, First name) with date of birth, and the class dropdown.")

body("When everything looks right, tap Continue at the bottom to go to Match Setup. If you "
     "loaded the wrong file, tap Load Different Spreadsheet.")

pagebreak()

# ============================ 6. MISSING DATA ============================
h1("6. Fixing missing or invalid data")
body("Shirt number, name, class and date of birth are mandatory, and the class must be one of "
     "the eight accepted values. If the spreadsheet has problems that would block the match, the "
     "app lists them clearly and prevents you from continuing until they are fixed.")
figure("missing-data", width=3.0,
       caption="Figure 7 — The Missing Data screen, grouping every blocking problem by type "
               "and pointing to the exact sheet, team, athlete and row.")

h2("How to read it")
bullet("Problems are grouped by type — for example “Players missing shirt number” or "
       "“Invalid player classes”.")
bullet("Each entry tells you exactly where to look: the sheet, the team, the athlete and the row number.")
bullet("A short hint reminds you of the rule (e.g. the only accepted class values).")

body("Correct the spreadsheet in Excel, then tap Load Different Spreadsheet and import it again. "
     "Small fixes (shirt number, class) can also be made directly in the Summary screen "
     "(Section 5) without editing the file.")

pagebreak()

# ============================ 7. MATCH SETUP ============================
h1("7. Match setup — choosing teams and the point limit")
body("On this screen you define the match: which two teams play and the maximum combined "
     "classification points allowed per team on court.")
figure("match-setup", width=3.0,
       caption="Figure 8 — Match Setup. Team A = Brazil - Men, Team B = Argentina - Men, "
               "point limit 14.0.")

h2("The fields")
h3("Select Team A and Select Team B")
bullet("Each is a dropdown listing every team from your spreadsheet, with its flag.")
bullet("By convention Team A wears the light (white) jersey and Team B wears the dark jersey.")
bullet("The two teams must be different — the app will not let you start a match of a team against itself.")

h3("Point Limit")
bullet("A dropdown from 7.0 to 16.0 in steps of 0.5. Official IWBF matches usually fall between 13.0 and 16.0.")
bullet("The default is 14.0. You can also change the limit later, during the match.")

h2("Same-gender check")
body("Official IWBF matches are played between teams of the same gender. If you pick a Men's "
     "team against a Women's team, the app shows a friendly warning and asks you to confirm "
     "before starting — it does not block you, in case you really do want a mixed/exhibition game.")
figure("match-setup-mismatch", width=3.0,
       caption="Figure 9 — The same-gender warning shown when Team A and Team B have "
               "different genders (here Brazil - Men vs Brazil - Women).")

body("When both teams are chosen and valid, tap Start Match to open the main screen.")

pagebreak()

# ============================ 8. LINEUP CONTROL ============================
h1("8. Lineup Control — the main match screen")
body("This is where you spend the game. On a tablet the screen shows three areas side by side: "
     "Team A's roster on the left, the basketball court in the centre, and Team B's roster on the "
     "right. A summary bar sits at the top and the operational buttons sit at the bottom.")
figure("lineup-empty", width=3.0,
       caption="Figure 10 — Lineup Control at the start of a match, before any player is "
               "selected. The court shows a hint for each team.")

h2("The top summary bar")
bullet("The competition name and the matchup, with both flags: Brazil - Men  vs  Argentina - Men.")
bullet("Two score boxes — Team A and Team B — each showing the current total versus the limit, e.g. 13.5 / 14.0.")
bullet("A Point Limit dropdown so you can change the limit at any time during the game.")

h2("Selecting players")
body("Tap any athlete in a team's side list to put them on court; tap again to take them off. "
     "Selected athletes are highlighted in the list and appear on the matching half of the court — "
     "Team A on the top half, Team B on the bottom half — each shown with the jersey number, "
     "surname and class. Team A wears white jerseys, Team B wears dark jerseys.")
figure("lineup-selected", width=3.0,
       caption="Figure 11 — Five players selected per team. Each team totals 13.5 points, "
               "comfortably under the 14.0 limit (shown in black).")

h2("The automatic point total")
body("Every time you select or deselect a player the app instantly re-sums that team's "
     "classification values and updates the score box. In Figure 11, Team A's on-court players "
     "(classes 1.0 + 2.0 + 3.0 + 3.5 + 4.0) total 13.5 against the 14.0 limit.")

h2("When a team goes over the limit")
body("If a team's total goes above the point limit, the app reacts immediately and stays in the "
     "warning state for as long as the team is over:")
bullet("The score box turns red.")
bullet("A persistent message “Point limit exceeded.” appears under that team's total.")
bullet("The device gives a short, gentle vibration (1–2 seconds) at the moment the limit is crossed. "
       "There is no sound.")
figure("lineup-overlimit", width=3.0,
       caption="Figure 12 — Team A is over the limit: 14.5 / 14.0 shown in red with "
               "“Point limit exceeded.” Team B stays at 13.5 / 14.0 in black.")
body("The warning clears on its own as soon as you bring the team back to or below the limit "
     "(for example by swapping a player for a lower-class one).")

h2("The five-player limit")
body("Each team can have between 0 and 5 players on court. Allowing 0 is intentional: during a "
     "substitution you can clear a team and pick a new five. If you try to select a sixth player, "
     "the app blocks it and shows a short message.")
figure("lineup-max5", width=3.0,
       caption="Figure 13 — Trying to add a sixth player to a full team shows "
               "“Only 5 players can be selected for Team A.”")

h2("The operational buttons")
make_table(
    ["Button", "What it does"],
    [
        ["Clear Team A", "Removes all of Team A's players from the court."],
        ["Clear Team B", "Removes all of Team B's players from the court."],
        ["Clear All", "Removes every player from the court (both teams)."],
        ["Change Teams", "Returns to Match Setup to pick a new matchup — without re-importing the spreadsheet. Ideal between two games."],
        ["Load New Spreadsheet", "Goes back to the start, clears the saved session, and asks for a new file."],
    ],
    widths=[1.7, 4.8],
)

h2("Leaving the match safely")
body("Because leaving could lose your current selection, both Change Teams and Load New "
     "Spreadsheet — and the system Back gesture — ask you to confirm first.")
figure("lineup-leave", width=3.0,
       caption="Figure 14 — The leave confirmation: “Are you sure you want to leave this "
               "match?” Tap Stay to keep playing or Leave to exit.")

h2("Screen stays awake")
body("While the Lineup Control screen is open the app keeps the screen awake, so the tablet "
     "will not dim or lock in the middle of a game. And, as explained in Section 4, your "
     "selection is saved continuously the whole time.")

pagebreak()

# ============================ 9. PHONE ============================
h1("9. Using the app on a phone")
body("The recommended device is a 10” (or larger) Android tablet, but the app is fully "
     "responsive and works on phones too. On a narrow screen the three side-by-side areas become "
     "three tabs instead — Team A, Court and Team B — so everything stays easy to reach.")
figure("phone", width=2.1,
       caption="Figure 15 — On a phone the roster lists and the court become tabs. The Court "
               "tab is shown here with both lineups in place.")
body("The logic is identical to the tablet: tap to select, read the live totals at the top, and "
     "watch for the over-the-limit alert. Only the arrangement of the screen changes.")

pagebreak()

# ============================ 10. PERSISTENCE ============================
h1("10. Data safety, persistence & stability")
body("The app is designed to be trusted during an official game, where you cannot afford to lose "
     "your work. Here is everything it does to keep your session safe.")

h2("Saved continuously, on the device only")
bullet("Your match — both teams and their rosters, the point limit, and who is on court — is saved "
       "to the device automatically after every change.")
bullet("Nothing is ever sent anywhere. There is no account and no server; the data lives only on the tablet.")

h2("Survives interruptions")
body("Your selection is preserved through everything Android might throw at a live game:")
bullet("The screen locks (or you lock it by accident) and you unlock it later.")
bullet("You switch to another app, or answer a phone call, and come back.")
bullet("A notification arrives.")
bullet("Android closes the app in the background to save battery, and you reopen it.")
body("In all of these cases you simply reopen the app and choose Restore Previous Session "
     "(Section 4) to pick up exactly where you left off.")

h2("Clearing the data")
body("The saved session is cleared whenever you deliberately choose Start from Scratch or "
     "Load New Spreadsheet. There is never any leftover data you did not ask to keep.")

pagebreak()

# ============================ 11. QUICK REFERENCE ============================
h1("11. Quick reference")

h2("Accepted values")
make_table(
    ["Setting", "Values"],
    [
        ["Player classification", "1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5"],
        ["Point limit", "7.0 to 16.0 in 0.5 steps (default 14.0)"],
        ["Players on court per team", "0 to 5 (a 6th is blocked)"],
        ["Date of birth input", "YYYY-MM-DD or DD/MM/YYYY"],
        ["File format", ".xlsx (Excel)"],
        ["Jersey colours", "Team A = light/white, Team B = dark"],
    ],
    widths=[2.4, 4.1],
)

h2("The key on-screen messages")
make_table(
    ["You see…", "It means…"],
    [
        ["Previous data found.", "A saved session exists — restore it or start from scratch."],
        ["Spreadsheet loaded successfully.", "The file was read with no blocking errors."],
        ["Some players are missing required information.", "Fix the listed problems before continuing."],
        ["Team A and Team B must be different.", "Pick two different teams."],
        ["Point limit exceeded.", "That team is over the limit right now (with vibration)."],
        ["Only 5 players can be selected for Team A.", "A team can have at most five players on court."],
        ["Are you sure you want to leave this match?", "Confirm before leaving so you don't lose your selection."],
    ],
    widths=[3.0, 3.5],
)

h2("The five-step game-day flow")
step(1, "Home → Load Reference Spreadsheet (or restore your last session).")
step(2, "Check the Summary, fix anything flagged, tap Continue.")
step(3, "Match Setup → choose Team A, Team B and the point limit → Start Match.")
step(4, "Tap players on/off; read the live totals; react to the red alert if a team goes over.")
step(5, "Use Change Teams between games, or Clear All to reset the court.")

closing = doc.add_paragraph()
closing.paragraph_format.space_before = Pt(20)
_set_run(closing.add_run("Carregar planilha → selecionar equipes → selecionar jogadores "
                         "→ somar pontos → alertar excesso."),
         italic=True, color=GREY, size=10)
c2 = doc.add_paragraph()
_set_run(c2.add_run("Load roster → pick teams → pick players → sum points "
                    "→ warn when exceeded."), italic=True, color=GOLD, size=11, bold=True)

doc.save(os.path.abspath(OUT))
print("Saved:", os.path.abspath(OUT))
