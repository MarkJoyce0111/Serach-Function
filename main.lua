--Search test app
--Searches a CSV flat file for country names using a search term.
--Searches with complete words or imcomplete chars (from start of word ie Aus for Australia or A for all countries starting with A.
--Gets index of Column location  for the rest of the data in the flat file. ie to extract all the other needed data for that country 
--we need the index in the flat file.
--Ignors Upper case. 


--[[
TODO's 
Error in Logic, - Reject all entries from column ONE (All the headers are here ie Country Code, Country.) when 
printing to the screen.
If you search C country shows up, and if you omit it from the list afganistan takes its place (yeah my spelling sux)
]]--

display.setStatusBar( display.DarkStatusBar )


CountryArray = {}
CountryToDisplay = {}
flag = 0
FirstTimeFlag = 0

ButtonGroup = display.newGroup()
debugGroup = display.newGroup()

local widget = require( "widget" )
local defaultField


--Search For complete string ie "Australia" case sensitive. NOT USED
function findit (array,search)
	daLength = #array
	for i = 1, daLength  do
	--print(coun[i].." "..i)
		if (array[i] == search) then
			--print("Found "..array[i].." at "..i) --Debug
			return i
		end
	end
	return 0
end
--TODO REMOVE DISCLUDE FROM FUNCTION. CREATE WALK AROUND. 

--Make a Country Array
--Ignors commas, "
--Convers Case to lower
--Disclude = a string, for example the column header like: country that is at position one of every column
function makeArray (aString,disclude)
	local constring = ""
	local array = {}
	for i = 0, #aString + 1 do
		local c = aString:sub(i,i)
		if (c~= "," and c ~= "\"") then --CSV separator and errors in Flat File
			constring = string.lower(constring..c)
			else
				if(constring ~= "")then
					array[#array + 1] = constring
					constring = ""
				else
					constring = ""
				end
		end
	end
	array[#array + 1] = constring --One left in the array
	return array
end

--Search partial string, not case sensitive. ie "A" or "Aust" etc
-- Display results as Buttons
--
function findChars(array,search)
	local someString = ""
	local startpos = 200
	local counter = 0 --match counter
	local flag = 0
	
	for i = 1, #array  do
		local success = 0
		someString = array[i]
		for k = 1, #someString do
			local c = someString:sub(k,k)--Get the chars to compare
			local d = search:sub(k,k)
			if (c == d) then --If chars the same increment match count
				success = success + 1
					else 
						success = success + 0	
			end
		end
		if (success == #search)then
			
			counter = counter + 1
			print("Found "..array[i].. " at index position "..i) --Debug		
			flag = 1
			local Sstr = i
			local Sstr = widget.newButton
			{
				shape = "roundedRect",
				fontSize = 17,
				left = 35,
				top = (30 * counter) + 20,
				width = 250,
				height = 20,
				id = i,
				label = array[i],
				strokeWidth=12,
				labelColor = { default={ 0, 0.3, 1 }, over={ 1, 1, 1, 0.5 } },
				fillColor = { default={ .1, 0.2, 0.7, 0.5 },over={ 1, 0.2, 0.5, 1 }}, 
				emboss=false,
				cornerRadius=8,
				--onRelease = handleButtonEvent --Not needed have event listener below
			}
			
			Sstr:addEventListener( "touch", handleButtonEvent ) 
			ButtonGroup:insert(Sstr)
			
		end		
	end
	if(flag ~= 1)then
		myText = display.newText(debugGroup,"Search Term Not Found!\n    Please Try Again",display.contentCenterX,startpos + (20*counter), 240, 300, native.systemFont, 22)
		myText:setFillColor( 0.8, 0, 0 )
		debugGroup:insert(myText)
		
	end
end

--
--Get Row Data (Country Data)
--From the file
function getRow(row)
	local path = system.pathForFile( "wjp.csv", system.ResourceDirectory )
	local file = io.open(path,"r")
	--local data = ""
	if file then
		--print("File Found")
		for i = 1, row do
			value = ""
			value = file:read("*l")
			if i == row then
				return value
			end
		end

	end
end
 
 --Render Row
 -- Renders scollable TableView of country data
 local function onRowRender( event )
	FirstTimeFlag = 1
    -- Get reference to the row group
    row = event.row
	
    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = 100
    --local rowWidth = 3000
 
    local rowTitle = display.newText(row,row.id, 0, 0,270,0,native.systemFont, 14 )
    rowTitle:setFillColor( 0,0,8 )
 
    -- Align the label left and vertically centered
    rowTitle.anchorX = 0
    rowTitle.x = 20      --Where inside the ROW
    rowTitle.y = 20
	rowHeight = rowHeight * 0.5
	isBounceEnabled = false

end

--
-- Function to handle button events 
-- Country Button Pressed!!!
-- 
function handleButtonEvent( event,self )

		--clear DebugGroup
		display.remove( debugGroup )
		dubugGroup = nil
		debugGroup = display.newGroup()

    if ( event.phase == "ended" ) then
        -- Code executed when the touch lifts off the object
        print( "touch ended on object " .. tostring(event.target.id) )

		tableView = widget.newTableView(
			{
			left = 0,
			top = 45,
			height = 500,        --Height and width of the actual Table View
			width = display.ContentWidthX ,
			onRowRender = onRowRender,
			onRowTouch = onRowTouch,
			listener = scrollListener,
			hideBackground = true
			}
		)
		for i = 1, 57 do
			response = getRow(i)
			local dummyArray = {}
			local titleArray = {}
			dummyArray = makeArray(response,"country code")
			CountryToDisplay[i] = dummyArray[event.target.id]
			titleArray[i] = dummyArray[1]
			print(CountryToDisplay[i])
			
			--print(dummyArray[i])
			dummyArray = nil
			
			local isCategory = false
			local rowHeight = 70 ----------------------------------------ROW HEIGHT
			local rowColor = { default={ 0, 0, 0}, over={ 0, 0, 0} }
			local lineColor = { 0, 0, 0 }
			
			local SectionString = titleArray[i]
			local DataString = CountryToDisplay[i]
			SectionString = SectionString:gsub("%a", string.upper,1)
			DataString = DataString:gsub("%a", string.upper,1)
			local id = SectionString.." - "..DataString
			
-- Insert a row into the tableView
			tableView:insertRow(
				{
					isCategory = isCategory,
					rowHeight = rowHeight,
					rowColor = rowColor,
					lineColor = lineColor,
					id = id,
				    --params = {}  -- Include custom data in the row
				}
			)		
		end
			
    end 
return true  -- Prevents tap/touch propagation to underlying objects
end


--Get the text from the textbox ie the search term, TEXT TERM ENTERED
--Call findChars to get results 
-- Handels blank Chars
-- Should: Clear Buttons, Clear Rows, Clear Debug
-- ButtonGroup: Country Buttons

local function textListener( event )
		-- Clear Debug Group
		display.remove( debugGroup )
		dubugGroup = nil
		debugGroup = display.newGroup()
		
		--Clear Button Group
		display.remove( ButtonGroup )
		ButtonGroup = nil
		ButtonGroup = display.newGroup()
		
		-- If there is a tableView on the screen at the moment. 
		--Kill It/Remove it
		if (FirstTimeFlag == 1) then
			tableView:deleteAllRows()
		end
		
		if (  event.phase == "submitted" ) then
	
			--Remove ButtonGroup and start another. Clears the results text. 
			display.remove( ButtonGroup )
			ButtonGroup = nil
			ButtonGroup = display.newGroup()
			
			-- Get text in box
			local someString = event.target.text
			if someString ~= "" then
				anotherString = string.lower(someString)
				--Search Chars
				findChars(CountryArray, anotherString)
				defaultField.text = ""
				
				else
				print("BLANK!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
					myText = display.newText(debugGroup,"Please enter a search term!",display.contentCenterX,display.contentCenterY, 240, 300, native.systemFont, 22)
					myText:setFillColor( 0.8, 0, 0 )
					debugGroup:insert(myText)
			end	

		end
end

 ----------------------------------------------Begin-----------------------------------
 --------------------------------------------------------------------------------------
 
-- Variables
country = ""
coun = {}
code = {}
position = 0 

local composer = require( "composer" )
 
-- Create a background which should appear behind all scenes
local background = display.newImage( "world.png", 30, 140)

--Open the CSV file.
local path = system.pathForFile( "wjp.csv", system.ResourceDirectory )

local file = io.open(path, "r")
if file then
	--print("File Found")
	country = file:read("*l")
	code = file:read("*l")
	region = file:read("*l")
	io.close (file)

	else
		print("Not working") --No file/Error
end

CountryArray = makeArray(country,"Country")
print(country)
-- Create text field
defaultField = native.newTextField( 160, 25, 180, 30 )
defaultField:addEventListener( "userInput", textListener )
SearchTitle = display.newText("Search",display.contentCenterX,0, 0, 0, native.systemFont, 14)
SearchTitle:setFillColor( 0.1, 0.7, 0.3 )

local image = display.newImageRect( "XXXXlogo.png", 90, 30 )
image.x = display.contentCenterX
image.y = 460

-- Hide the object
image.isVisible = true
 
 
 
 
 
 
-- Remove it
--image:removeSelf()
--image = nil
--Button NOT USED - text cleared in 'event'
--button1.x = display.contentCenterX
--button1.y = 400

--Debug
--position = findit(CountryArray,"Australia")
--print("Found target at position ", position)
--findChars(CountryArray,"St")
