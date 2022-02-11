# Getting Started ---------------------------------------------------------

# install the DataEditR package
install.packages("DataEditR")

# Development version of DataEditR
library(devtools)
devtools::install_github("DillonHammill/DataEditR")


# install Dillon Hammill's fork of rhandsontable
devtools::install_github("DillonHammill/rhandsontable")

# load in the libraries
library(DataEditR)
library(rhandsontable)

# Loading the window ------------------------------------------------------

# load the window (empty)
data_edit()

# load the window in the dialog pane
data_edit(viewer = 'dialog')

# load the window in the viewer pane
data_edit(viewer = 'viewer')

# load the window in a browser
data_edit(viewer = 'browser')

# setting rows and columns
data_edit(c(5,10))

# setting the column names
data_edit(c('First', 'Last', 'Job', 'Company'))

data_edit(mtcars)
# Exploring the Parameters ------------------------------------------------
# Column parameters

# binding a column to the dataset
data_edit(x = mtcars,
          col_bind = list(car_name = rownames(mtcars),
                          test_col = 0))

# allowing users to add or remove columns (default is TRUE)
# if FALSE, user cannot add nor remove columns
data_edit(x = mtcars,
          col_edit = F)

# applying column options to columns
# options include: dropdown menus, dates, checkboxes, and passwords

# Dropdown menu example
data_edit(x = mtcars,
          col_bind = 'Car_Color',
          col_options = list(Car_Color = c('red', 'blue', 'yellow')))

# date example
data_edit(x = mtcars,
          col_bind = 'Date_Man',
          col_options = list(Date_Man = 'date'))

# checkbox example
data_edit(x = mtcars,
          col_bind = 'Cool_Car',
          col_options = list(Cool_Car = c(TRUE, FALSE)))

# password example
data_edit(x = mtcars,
          col_bind = 'Secret_Col',
          col_options = list(Secret_Col = 'password'))

# stretch the columns by default
data_edit(x = mtcars,
          col_stretch = T)

# convert categorical columns to factors
mtcars2 = mtcars
mtcars2$Car_Name = rownames(mtcars2)

data_edit(x = mtcars2,
          col_factor = TRUE) %>% 
  str()

# indicate which column names cannot be altered
data_edit(x = mtcars,
          col_names = c('mpg', 'cyl'))

# indicate which columns cannot be edited
data_edit(x = mtcars,
          col_readonly = 'cyl')

# add rows to your data
data_edit(x = mtcars,
          row_bind = list(Last_Row = 0))

# prevent user from adding rows
data_edit(x = mtcars,
          row_edit = F)

# save file as
data_edit(x = mtcars,
          save_as = 'mtcars_edited.csv')

# add a title to the top of your window
data_edit(x = mtcars,
          title = 'DataEditR Window')

# add a logo to the top of your window
img_file = 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/R_logo.svg/2560px-R_logo.svg.png'

data_edit(x = mtcars,
          title = 'DataEditR Window',
          logo = img_file)

# resize the logo
data_edit(x = mtcars,
          title = 'DataEditR Window',
          logo = img_file,
          logo_size = 60)

# position the logo (left or right)
data_edit(x = mtcars,
          title = 'DataEditR Window',
          logo = img_file,
          logo_size = 30,
          logo_side = 'right')

# resize the viewer window
data_edit(x = mtcars,
          viewer_height = 1200,
          viewer_width = 2000)

# change the theme of your window
# you can find the RShiny themes here: https://rstudio.github.io/shinythemes/
data_edit(x = mtcars,
          theme = 'united')

# setting the read function with arugments
# default of read_fun = read.csv
# default of write_fun = write.csv
library(xlsx)
mtcars2 <- data_edit(x = 'mtcars_excel.xlsx',
          save_as = 'mtcars_edited_excel.xlsx',
          read_fun = 'read.xlsx',
          read_args = list(startRow = 1,
                           endRow = 21,
                           sheetIndex = 1),
          write_fun = 'write.xlsx',
          write_args = list(row.names = T,
                            password = 'test123',
                            sheetName = 'CARS'))

# setting quiet mode, which suppresses messages
data_edit(x = mtcars,
          quiet = T)

# hiding some of the main window buttons
data_edit(x = mtcars,
          hide = T)

# store the code recorded from editing the dataset
data_edit(x = mtcars,
          code = 'The_Code.R')

