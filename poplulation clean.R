df=read_excel("C:\\Users\\Sarah El-Safty\\Downloads\\Population.xlsx")
View(df)
# 1. التنظيف
df<- df %>%
  clean_names() %>% # تحول 'Zip Code' إلى zip_code و 'Population' إلى population تلقائياً
#بتشيل أي صفوف مكررة بالكامل (Duplicate rows) من الـ Dataframe.
  distinct() %>%
#يحوّل كل البيانات لنصوص ويمسح أي مسافات زيادات متدارية في أول أو آخر الكلمات في الجدول كله.
  mutate(across(everything(), ~ str_trim(as.character(.)))) %>%
  View(df)
# تنظيف الرمز البريدي
mutate(
  zip_code = str_remove_all(zip_code, "[ \\-]"),
  zip_code = str_replace_all(zip_code, "(?i)o", "0"),
  zip_code = str_extract(zip_code, "\\d{5}")
) %>%
  View(df)
# تنظيف السكان
  mutate(
    population = str_replace_all(population, "(?i)k", "000"),
    population = str_remove_all(population, ","),
    population = suppressWarnings(as.numeric(population)),
    population = round(population)
  ) %>%
    View(df)
  colnames(df)[1] <- "X"
  colnames(df)[2] <- "Zip_Code"
  # التصفية
  filter(
    !is.na(Zip_Code),
    !is.na(Population),
    is.finite(population),
    Population > 0
  )
 View(df)
