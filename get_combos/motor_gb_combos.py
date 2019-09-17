import time
import os 
import math 
from time import sleep 


from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.by import By

#https://stackoverflow.com/questions/26566799/wait-until-page-is-loaded-with-selenium-webdriver-for-python
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

from selenium.common.exceptions import ElementNotVisibleException
from selenium.common.exceptions import NoSuchElementException



def main():
	# Open up new chrome window
	# https://stackoverflow.com/questions/40555930/selenium-chromedriver-executable-needs-to-be-in-path

	# https://stackoverflow.com/questions/16511384/using-extensions-with-selenium-python
	
	# File to wrwite out to 
	num_unknown = 0


	#options = webdriver.ChromeOptions()
	#options.add_extension('./leklllfdadjjglhllebogdjfdipdjhhp.crx')

	#driver = webdriver.Chrome(executable_path='./chromedriver', chrome_options=options)	# on mac 
	driver = webdriver.Chrome('/usr/bin/chromedriver')


	driver.implicitly_wait(8) 	# might be nad slow 
	wait = WebDriverWait(driver, 4)		# may need 4


	# Go to main page -- try to get for USA version but being weird 
	#start_url = "https://www.maxongroup.in/maxon/view/category/motor?etcc_cu=onsite&etcc_med_onsite=Product&etcc_cmp_onsite=ECX+SPEED+program&etcc_plc=Overview-Page-brushless-DC-Motors&etcc_var=%5bin%5d%23en%23_d_&target=filter&filterCategory=ECX"

	# https://intoli.com/blog/chrome-extensions-with-selenium/

	# could do a smarter wait here if need 
	print('Navigating to motor page')
	start_url = "https://www.maxongroup.in/maxon/view/category/motor?etcc_cu=onsite&etcc_med_onsite=Product&etcc_cmp_onsite=ECX+SPEED+program&etcc_plc=Overview-Page-brushless-DC-Motors"
	driver.get(start_url) 

	#try:
	#	myElem = WebDriverWait(driver, delay).until(EC.presence_of_element_located((By.NAME, 'category')))
	#	print "Page is ready!"
	#except:
   	# 	print "Loading took too much time!"

	# Click on "ALL" -- or get so that dont need to 
	"""
	print('Clicking on ALL')

	sel_all = driver.find_element_by_name('category')
	sel_all.click() 	# should select all 
	

	"""
	wait.until(EC.invisibility_of_element_located((By.XPATH,
	                       "//div[@class='blockUI blockOverlay']")))

	# Get total number of motors so we can get proper number of pages and links 
	gg = driver.find_element_by_id('articleList')
	heading = gg.find_element_by_tag_name('h2')
	spans = heading.find_element_by_tag_name('span')
	spans_text = spans.text.encode("ascii")
	pp = spans_text.split(" ")
	print("pp: ", pp)
	num_motor = int(pp[-1])
	num_motor_pages = int(math.ceil(num_motor/10.0))

	# Get total number pages we will need to loop through 
	print('Num motor pages: ', num_motor_pages)

	# Get hyperlink for first or second page so we can return to it 
	next_page_button = driver.find_element_by_partial_link_text("forward")
	page_link = next_page_button.get_attribute('href').encode("ascii")
	page_url_start = page_link[0: -1]

	print('page start: '+ page_url_start)

	time.sleep(2)   # shouldnt really need -- want to just wait for elemtnes to be clickabel
	
	#main_window = driver.current_window_handle

	#num_motor_pages = 2

	# TODO -- individual pages -- link later (problem is unknowns)
	# Can over come this by overwriting 

	for p in range(1, 64):

		# we will write a new document for every page because this keeps failing
		file_name = './combos/combopage_%0.3d.txt' % (p)
		f = open(file_name, "w+"); 

		page_link = page_url_start + str(p + 1)		# TODO --- back to page 1 
		#page_link = page_url_start + str(p + 3)		# TODO --- back to page 1 

		num_links = min(10, num_motor - 10*p)
		print('============= Page: ' + str(p) + " =================")
		#print('Link : ', page_link)
		for i in range(num_links):
		#for i in range(2):
			# Select the motor button -- may have been on a gearbox page
			try:
				#print('>>>>>>> Clicking on motor button to switch to motor page')
				motor_button = driver.find_element_by_xpath("//img[@src='/medias/sys_master/root/8796341796894/motor.png']")
				motor_button.click()
				wait.until(EC.invisibility_of_element_located((By.XPATH,
	                       "//div[@class='blockUI blockOverlay']")))
				time.sleep(1)
			except:
				pass

			#print('already on a motor page')

			# Get us to the correct page 
			arg_string = "arguments[0].setAttribute('href', '" + page_link +"')"
			
			try:
				next_page_button = driver.find_element_by_partial_link_text("forward")
				driver.execute_script(arg_string, next_page_button)
				next_page_button.click()
			except:
				pass 

			# Get the list of motor product numbers for this page -- read the table
			wait.until(EC.invisibility_of_element_located((By.XPATH,
	                       "//div[@class='blockUI blockOverlay']"))) 
			motor_table = driver.find_element_by_tag_name('table')
			motor_rows = motor_table.find_elements_by_tag_name("tr")		# can get prod numbers 
			row = motor_rows[i + 2]			# first 2 are something else 

			motor_num = row.text[0:6]

			
			# check if numeric 
			if not(motor_num.isdigit()):
				motor_num = "unknown_" + str(num_unknown)
				num_unknown = num_unknown + 1
			f.write(motor_num)

			#driver.switch_to_window(main_window)  # shouldnt need this


			wait.until(EC.invisibility_of_element_located((By.XPATH,
                       "//div[@class='blockUI blockOverlay']")))


			print(" link: " + str(i))
			links = driver.find_elements_by_class_name('buttonCol'); 	# recompute because going stale
			links[i].click()		# now wait i guess? 

			
			comb_xpath = "//button[@name='submit'][@type='submit']"
			#https://stackoverflow.com/questions/49921128/selenium-cant-click-element-because-other-element-obscures-it
			wait.until(EC.invisibility_of_element_located((By.XPATH,
              "//div[@class='blockUI blockOverlay']")))
			comb_button = driver.find_element_by_xpath(comb_xpath)
			#comb_button = wait.until(EC.element_to_be_clickable((By.XPATH, comb_xpath)));
			#print('Clicking on combination!')
			wait.until(EC.invisibility_of_element_located((By.XPATH,
              "//div[@class='blockUI blockOverlay']")))


			comb_button.click() 	# pull up new form 

			# need a try catch on this 
			has_gb = False
		
			try:
				gear_link = driver.find_element_by_partial_link_text('gear') # to trigger error
				#gear_link = driver.find_element_by_partial_link_text('Select')
				has_gb = True				
				wait.until(EC.invisibility_of_element_located((By.XPATH,
              			"//div[@class='blockUI blockOverlay']")))
				#gear_link.send_keys(Keys.COMMAND + Keys.RETURN) # or + "2"
				gear_link.click() 

				# Switch to new tab -- do things, then close 
				#wins = driver.window_handles
				#driver.switch_to_window(wins[-1])	# most recently openend tab 
				#print('Weve opened new window and started searching...')
				#print(wins)
				wait.until(EC.invisibility_of_element_located((By.XPATH,
              			"//div[@class='blockUI blockOverlay']")))
				# time.sleep(1)		# maybe 4 

				# May be issue with this not comming up
				gg = driver.find_element_by_id('articleList')
				heading = gg.find_element_by_tag_name('h2')
				spans = heading.find_element_by_tag_name('span')
				spans_text = spans.text.encode("ascii")
				pp = spans_text.split(" ")
				num_gb = int(pp[-1])
				print('pp: ', pp)
				print('Num gb: ', num_gb)
				num_gb_pages = int(math.ceil(num_gb/10.0))

				print("gb pages: ", num_gb_pages)

				#print('looping through gearbox pages')
				for gb_page in range(num_gb_pages):
					print("gb page: ", str(gb_page))

					#url_idx_end = url_idx_start + find(gear_data(url_idx_start:end) == '"', 1, 'first') - 2; 
        			#spec_url = ['https://www.maxongroup.com', gear_data(url_idx_start:url_idx_end), '?_=1']; 
        			#system(['curl ', spec_url, sprintf(' > ./gears/gear_%0.4d.html', idx)]); 
        			#idx = idx + 1;


        			
					gear_table = driver.find_element_by_tag_name('table')
					gear_rows = gear_table.find_elements_by_tag_name("tr")

					ng = len(gear_rows) - 2 # 2 header rows 

					for j in range(ng):
						gear_row = gear_rows[j + 2]
						#print(gear_row.text)
						gear_num = gear_row.text[0:6]

						if not(gear_num.isdigit()):
							gear_desc = gear_row.find_element_by_class_name('articleDesc')
							gear_num = gear_desc.text.encode('utf-8')
		
							
						f.write('; ' + gear_num)

					if (gb_page < num_gb_pages - 1):
						next_page_button = driver.find_element_by_partial_link_text("forward")
						wait.until(EC.invisibility_of_element_located((By.XPATH,
			              				"//div[@class='blockUI blockOverlay']")))
						next_page_button.click()
						wait.until(EC.invisibility_of_element_located((By.XPATH,
			              				"//div[@class='blockUI blockOverlay']")))
					
	
				#driver.close()
				# get the whole list -- then delete the window 

				#driver.switch_to_window(main_window)  # not sue if need 
				# driver.switch_to_window(driver.window_handles[0])
				#print('switching to main window')
				#driver.switch_to_window(main_window)
				#driver.switch_to_window(wins[0])	# most recently openend tab 

				#time.sleep(2)		# maybe 5 
			except NoSuchElementException as e:
				if has_gb:
					print(e)
					return
				else:
					print('No gearboxes found')
				
			# Delete the combination after getting the info we need 			
			try:
				#print('Deleting combination...')
				del_com = driver.find_element_by_class_name('delete')
				wait.until(EC.invisibility_of_element_located((By.XPATH,
	              "//div[@class='blockUI blockOverlay']")))
				del_com.click() 
				wait.until(EC.invisibility_of_element_located((By.XPATH,
            	           "//div[@class='blockUI blockOverlay']")))
			except:
				print('No combinations open to delete')

			f.write('\n')	


		# Go to next page 
		f.close()
		print('Going on to next page......')
	driver.close()	

if __name__ == "__main__":
    main()