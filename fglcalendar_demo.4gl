IMPORT util

IMPORT FGL fglcalendar

DEFINE rec RECORD
               curr_type SMALLINT,
               curr_theme SMALLINT,
               curr_year SMALLINT,
               curr_month SMALLINT,
               show_daynames BOOLEAN,
               show_daynums  BOOLEAN,
               show_weeknums BOOLEAN,
               calendar STRING,
               selected_date DATE
           END RECORD

MAIN
    DEFINE cid INTEGER

    CALL add_presentation_styles()

    OPEN FORM f1 FROM "fglcalendar_demo"
    DISPLAY FORM f1

    OPTIONS FIELD ORDER FORM

    CALL fglcalendar.initialize()

    LET cid = fglcalendar.create("formonly.calendar")

    LET rec.curr_type = FGLCALENDAR_TYPE_DEFAULT
    CALL set_type(cid, rec.curr_type)

    LET rec.curr_theme = FGLCALENDAR_THEME_DEFAULT
    CALL fglcalendar.setColorTheme(cid, rec.curr_theme)

    LET rec.curr_year = YEAR(TODAY)
    LET rec.curr_month = MONTH(TODAY)

    LET rec.selected_date = TODAY
    CALL fglcalendar.addSelectedDate(cid, rec.selected_date)
    CALL fglcalendar.addSelectedDate(cid, rec.selected_date-2)
    CALL fglcalendar.addSelectedDate(cid, rec.selected_date-4)
    CALL fglcalendar.addSelectedDate(cid, rec.selected_date+5)
    CALL fglcalendar.addSelectedDate(cid, rec.selected_date+15)

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

        ON CHANGE curr_year
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)
        ON CHANGE curr_month
           IF rec.curr_month == 0 THEN
              LET rec.curr_year = rec.curr_year-1
              LET rec.curr_month = 12
           END IF
           IF rec.curr_month == 13 THEN
              LET rec.curr_year = rec.curr_year+1
              LET rec.curr_month = 1
           END IF
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
           LET rec.selected_date = fglcalendar.getSelectedDateFromValue(cid, rec.calendar)
           IF fglcalendar.isSelectedDate(cid, rec.selected_date) THEN
              CALL fglcalendar.removeSelectedDate(cid, rec.selected_date)
           ELSE
              CALL fglcalendar.addSelectedDate(cid, rec.selected_date)
           END IF
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

        ON ACTION clear ATTRIBUTES(TEXT="Clear")
           CALL fglcalendar.clearSelectedDates(cid)
           CALL fglcalendar.display(cid, rec.curr_year, rec.curr_month)

    END INPUT

    CALL fglcalendar.destroy(cid)
    CALL fglcalendar.finalize()

END MAIN

FUNCTION set_type(cid,type)
    DEFINE cid, type SMALLINT
    CALL fglcalendar.setViewType(cid, type)
    IF type == FGLCALENDAR_TYPE_DEFAULT THEN
       CALL fglcalendar.setDayNames(cid, "Lun|Mar|Mer|Jeu|Ven|Sam|Dim")
    ELSE
       CALL fglcalendar.setDayNames(cid, "L|M|M|J|V|S|D")
    END IF
END FUNCTION

FUNCTION cmb_init_types(cmb)
    DEFINE cmb ui.ComboBox
    CALL cmb.addItem(FGLCALENDAR_TYPE_DEFAULT, "Default")
    CALL cmb.addItem(FGLCALENDAR_TYPE_TEXT,    "Text")
    CALL cmb.addItem(FGLCALENDAR_TYPE_ICON,    "Icon")
    CALL cmb.addItem(FGLCALENDAR_TYPE_DOTS,    "Dots")
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

FUNCTION cmb_init_month(cmb)
    DEFINE cmb ui.ComboBox
    DEFINE m SMALLINT
    CALL cmb.addItem(0, "<--")
    FOR m=1 TO 12
        CALL cmb.addItem(m, month_name(m))
    END FOR
    CALL cmb.addItem(13, "-->")
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
       CALL set_style_attribute(nn, "fontSize", "large" )
    END IF
END FUNCTION
