IMPORT FGL fglcalendar

DEFINE rec RECORD
               curr_type SMALLINT,
               curr_theme SMALLINT,
               curr_mode SMALLINT,
               curr_year SMALLINT,
               curr_month SMALLINT,
               show_daynames BOOLEAN,
               show_daynums  BOOLEAN,
               show_weeknums BOOLEAN,
               calendar STRING,
               selected_date_1 DATE,
               selected_date_2 DATE
           END RECORD

CONSTANT SM_SINGLE = 1
CONSTANT SM_MULTI = 2
CONSTANT SM_RANGE = 3

MAIN
    DEFINE cid INTEGER
    DEFINE sf CHAR(1)
    DEFINE sd DATE

    CALL add_presentation_styles()

    OPEN FORM f1 FROM "fglcalendar_demo"
    DISPLAY FORM f1

    OPTIONS FIELD ORDER FORM, INPUT WRAP

    CALL fglcalendar.initialize()

    LET cid = fglcalendar.create("formonly.calendar")

    LET rec.curr_type = FGLCALENDAR_TYPE_DEFAULT
    CALL set_type(cid, rec.curr_type)

    LET rec.curr_theme = FGLCALENDAR_THEME_DEFAULT
    CALL fglcalendar.setColorTheme(cid, rec.curr_theme)

    LET rec.curr_mode = SM_MULTI

    LET rec.curr_year = YEAR(TODAY)
    LET rec.curr_month = MONTH(TODAY)

    LET rec.selected_date_1 = TODAY
    LET rec.selected_date_2 = NULL
    CALL fglcalendar.addSelectedDate(cid, rec.selected_date_1)
    CALL fglcalendar.addSelectedDate(cid, rec.selected_date_1-2)
    CALL fglcalendar.addSelectedDate(cid, rec.selected_date_1-4)

    LET rec.show_daynames = TRUE
    CALL fglcalendar.showDayNames(cid, rec.show_daynames)

    LET rec.show_daynums = TRUE
    CALL fglcalendar.showDayNumbers(cid, rec.show_daynums)

    LET rec.show_weeknums = FALSE
    CALL fglcalendar.showWeekNumbers(cid, rec.show_weeknums)

    CALL ui.Interface.refresh() -- force form/webcomponent display before sending SVG
    CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

    INPUT BY NAME rec.*
          ATTRIBUTES( WITHOUT DEFAULTS, UNBUFFERED, ACCEPT=FALSE )

        ON CHANGE curr_type
           CALL set_type(cid, rec.curr_type)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON CHANGE curr_theme
           CALL fglcalendar.setColorTheme(cid, rec.curr_theme)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON CHANGE curr_mode
           LET sf = "F"
           LET rec.selected_date_1 = NULL
           LET rec.selected_date_2 = NULL
           CALL fglcalendar.clearSelectedDates(cid)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON CHANGE curr_year
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)
        ON CHANGE curr_month
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)
        ON ACTION year_month_decr ATTRIBUTES(ACCELERATOR="CONTROL-P")
           CALL year_month_change(rec.curr_year, rec.curr_month, -1)
                RETURNING rec.curr_year, rec.curr_month
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)
        ON ACTION year_month_incr ATTRIBUTES(ACCELERATOR="CONTROL-N")
           CALL year_month_change(rec.curr_year, rec.curr_month, +1)
                RETURNING rec.curr_year, rec.curr_month
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON CHANGE show_daynames
           CALL fglcalendar.showDayNames(cid, rec.show_daynames)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON CHANGE show_daynums
           CALL fglcalendar.showDayNumbers(cid, rec.show_daynums)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON CHANGE show_weeknums
           CALL fglcalendar.showWeekNumbers(cid, rec.show_weeknums)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON ACTION calendar_selection
           LET sd = fglcalendar.getSelectedDateFromValue(cid, rec.calendar)
           CASE rec.curr_mode
           WHEN SM_SINGLE
              LET rec.selected_date_1 = sd
              LET rec.selected_date_2 = NULL
              CALL fglcalendar.clearSelectedDates(cid)
              CALL fglcalendar.addSelectedDate(cid, sd)
           WHEN SM_MULTI
              LET rec.selected_date_1 = sd
              LET rec.selected_date_2 = NULL
              IF fglcalendar.isSelectedDate(cid, sd) THEN
                 CALL fglcalendar.removeSelectedDate(cid, sd)
              ELSE
                 CALL fglcalendar.addSelectedDate(cid, sd)
              END IF
           WHEN SM_RANGE
              CASE
              WHEN rec.selected_date_1 IS NULL OR sd < rec.selected_date_1
                  LET rec.selected_date_1 = sd; LET sf = "E"
              WHEN rec.selected_date_2 IS NULL OR sd > rec.selected_date_2
                  LET rec.selected_date_2 = sd; LET sf = "S"
              OTHERWISE
                  IF sf == "S" THEN
                      LET rec.selected_date_1 = sd; LET sf = "E"
                  ELSE
                      LET rec.selected_date_2 = sd; LET sf = "S"
                  END IF
              END CASE
              CALL fglcalendar.clearSelectedDates(cid)
              CALL fglcalendar.addSelectedDateRange(cid, rec.selected_date_1, rec.selected_date_2)
           END CASE
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON ACTION clear ATTRIBUTES(TEXT="Clear")
           LET rec.selected_date_1 = NULL
           LET rec.selected_date_2 = NULL
           CALL fglcalendar.clearSelectedDates(cid)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON CHANGE selected_date_1, selected_date_2
           CALL fglcalendar.clearSelectedDates(cid)
           CALL fglcalendar.addSelectedDateRange(cid, rec.selected_date_1, rec.selected_date_2)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

    END INPUT

    CALL fglcalendar.destroy(cid)
    CALL fglcalendar.finalize()

END MAIN

FUNCTION set_type(cid,type)
    DEFINE cid, type SMALLINT
    CALL fglcalendar.setViewType(cid, type)
    IF type == FGLCALENDAR_TYPE_DEFAULT THEN
       CALL fglcalendar.setDayNames(cid, "Mon|Tue|Wed|Thu|Fri|Sat|Sun")
    ELSE
       CALL fglcalendar.setDayNames(cid, "M|T|W|T|F|S|S")
    END IF
END FUNCTION

FUNCTION cmb_init_types(cmb)
    DEFINE cmb ui.ComboBox
    CALL cmb.addItem(FGLCALENDAR_TYPE_DEFAULT, "Default")
    CALL cmb.addItem(FGLCALENDAR_TYPE_TEXT,    "Text")
    CALL cmb.addItem(FGLCALENDAR_TYPE_ICON,    "Icon")
    CALL cmb.addItem(FGLCALENDAR_TYPE_DOTS,    "Dots")
    CALL cmb.addItem(FGLCALENDAR_TYPE_SNAKE,   "Snake")
END FUNCTION

FUNCTION cmb_init_themes(cmb)
    DEFINE cmb ui.ComboBox
    CALL cmb.addItem(FGLCALENDAR_THEME_DEFAULT, "Default")
    CALL cmb.addItem(FGLCALENDAR_THEME_SAHARA,  "Sahara")
    CALL cmb.addItem(FGLCALENDAR_THEME_PACIFIC, "Pacific")
    CALL cmb.addItem(FGLCALENDAR_THEME_AMAZON,  "Amazon")
    CALL cmb.addItem(FGLCALENDAR_THEME_VIOLA,   "Viola")
    CALL cmb.addItem(FGLCALENDAR_THEME_CHILI,   "Chili")
END FUNCTION

FUNCTION cmb_init_modes(cmb)
    DEFINE cmb ui.ComboBox
    CALL cmb.addItem(SM_SINGLE,"Single selection")
    CALL cmb.addItem(SM_MULTI,"Multi selection")
    CALL cmb.addItem(SM_RANGE,"Range selection")
END FUNCTION

FUNCTION cmb_init_month(cmb)
    DEFINE cmb ui.ComboBox
    DEFINE m SMALLINT
    FOR m=1 TO 12
        CALL cmb.addItem(m, month_name(m))
    END FOR
END FUNCTION

FUNCTION month_name(m)
    DEFINE m SMALLINT
    CASE m
       WHEN 1 RETURN "January"
       WHEN 2 RETURN "February"
       WHEN 3 RETURN "March"
       WHEN 4 RETURN "April"
       WHEN 5 RETURN "May"
       WHEN 6 RETURN "June"
       WHEN 7 RETURN "July"
       WHEN 8 RETURN "August"
       WHEN 9 RETURN "September"
       WHEN 10 RETURN "October"
       WHEN 11 RETURN "November"
       WHEN 12 RETURN "December"
    END CASE
    RETURN NULL
END FUNCTION

PRIVATE FUNCTION get_aui_node(p, tagname, name)
    DEFINE p om.DomNode,
           tagname STRING,
           name STRING
    DEFINE nl om.NodeList
    IF name IS NOT NULL THEN
       LET nl = p.selectByPath(SFMT("//%1[@name=\"%2\"]",tagname,name))
    ELSE
       LET nl = p.selectByPath(SFMT("//%1",tagname))
    END IF
    IF nl.getLength() == 1 THEN
       RETURN nl.item(1)
    ELSE
       RETURN NULL
    END IF
END FUNCTION

PRIVATE FUNCTION add_style(pn, name)
    DEFINE pn om.DomNode,
           name STRING
    DEFINE nn om.DomNode
    LET nn = get_aui_node(pn, "Style", name)
    IF nn IS NOT NULL THEN RETURN NULL END IF
    LET nn = pn.createChild("Style")
    CALL nn.setAttribute("name", name)
    RETURN nn
END FUNCTION

PRIVATE FUNCTION set_style_attribute(pn, name, value)
    DEFINE pn om.DomNode,
           name STRING,
           value STRING
    DEFINE sa om.DomNode
    LET sa = get_aui_node(pn, "StyleAttribute", name)
    IF sa IS NULL THEN
       LET sa = pn.createChild("StyleAttribute")
       CALL sa.setAttribute("name", name)
    END IF
    CALL sa.setAttribute("value", value)
END FUNCTION

PRIVATE FUNCTION add_presentation_styles()
    DEFINE rn om.DomNode,
           sl om.DomNode,
           nn om.DomNode
    LET rn = ui.Interface.getRootNode()
    LET sl = get_aui_node(rn, "StyleList", NULL)
    --
    LET nn = add_style(sl, ".bigfont")
    IF nn IS NOT NULL THEN
       CALL set_style_attribute(nn, "fontSize", "1.2em" )
    END IF
END FUNCTION

PRIVATE FUNCTION year_month_change(y, m, d)
    DEFINE y SMALLINT, m SMALLINT, d SMALLINT
    LET m = m + d
    IF m == 0 THEN
        LET y = y - 1
        LET m = 12
    END IF
    IF m == 13 THEN
        LET y = y + 1
        LET m = 1
    END IF
    RETURN y, m
END FUNCTION
