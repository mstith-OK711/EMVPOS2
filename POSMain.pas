  {-----------------------------------------------------------------------------
  Unit:      POSMain
  Author:    Gary Whetton
  History:
             *** base build 297 ***
             * Include directive for condition compile symbols moved from last to first (POSMain.pas).
             * Serialize threads for tax calculation and posting (//20041215 in POSMain.pas)
             * Detect missing card information (//20041216 in NBSCC.pas)
             * Require field for approval number and voucher number for EBT voucher transactions (//20041220 in NBSCC.pas)
             * Correct calculation of food stamp tax exemp tion (//20041228)
             * Correct tax calculation for EBT FS return transactions (//20050103 in POSMain.pas and NBSCC.pas)
             * Correct accumulation of non-taxable items tendered with food stamps. (//20050103b in POSMain.pas)
             * Check validity of expiration date entered for manual EBT.   (//20050113 in NBSCC.pas)
             * Added code to XMD to verify db connection and reconnect if required
             *** Base Build 298 ***
             * Added code to recalcultesale to allow only amounts up to the food stampable taxable amounts to be considered
               when reducing taxable amounts in the tax list for prior food stamp tenders.  In earlier versions, prior food
               stamp tenders would be deducted from the tax  list in the wrong proportions resulting in incorrect total sales
               amounts for various tax types (including the tax type of "non-taxable").  Also, transactions involving
               merchandise returns would invoke the same code, so tax totals could be off even without involving EBT FS transactions.
             *** Base build 299 ***
             * Moved XMD issue code to after amount due adjustment in ProcesskeyMed.  Problem caused by FS tax adjustment after XMD
               qualification.
             * Added code to correct issues with tax calcs.
             * Added code to ResetDay to ensure DB is open.
             *** Base Build 300 ***
             * Corrected an issue in POS that was causing an error when updating the fuel grade display on pumps of logged off terminals
             * Added code to verify db connection during and immediately after logon
             *** Base Build 301 ***
             * Added code to NBSCC to handle EBT FS vouchers.
             * Added code to NBSCC to handle input of exp date on EBT_FS and EBT_CB during manual entry.
             * Added code to CloseDay to clear track data befor zipping files.
             * Added/Modified NBSCC code to address a problem where the vehicle number prompt would hang if it is not
               the last prompt before authorization (encountered Jan. 13 at store #450 with a M/C Fleet transaction).
             * Also, typo errors from integration of changes previous change. (//20050114 in NBSCC.pas)
             * Added code to XMD to only check for UPC/Header updates on expired time (used to check on POS timer)//20050120
             * Added code to XMD to clear old UPC/Headers that have expired (even if not deleted by host)//20050120
             *** Base build 302 ***
             * Removed threading in POSLog.LogSale (threads were using up all the memory)
             *** Base build 304 ***
             * Added try except wrapper to cleanup of files on backup terminal (//20050201)
             * Added code to suppport merged TOC / 7-11 versions of credit server (conditional compile VERSION_MERGE //20050203)
             *** Base build 305 ***
             * Added code to implement fuel discounts by bin range (//20050207)
             * Added code to handle non enforcement of gift restrictions
             * Added code for handling outbound DCOM fuel messages in a list versus direct if fuel is busy (//20050217)
             *** Base build 306 ***
             * Added 'input-synchronous' trap to FuelBusy code to prevent thread errors (//20050228)
             * Added 'input-synchronous' trap to items scanned with Cyclone scanner (//20050228)
             * Added code to place scanned information into records and lists and use PostMessage to prevent input-synchronous
               errors when input is from serial devices
             *** Base builds 2.0.3.000 & 2.0.4.000
             * Includes changes for Fuel First card support (conditional compile FUEL_FIRST disabled for this release).
             * Includes support for fuel export file for Snow Bird. (new unit SnowBirEx and conditional compile LEATHERS)
             * Re-write of Inventory.pas and Inventory.dfm (from similar form in SysMgr).
             * Pass OPOS scanner input to inventory screen if visible (//inv2 in OPOSScannerDataEvent)
             * Export table InvAudit during EOD (//inv2 in CloseDat.pas)
             * New PIN Pad interface (IFDEF DEV_PIN_PAD)
             *** Base build 2.0.3.008
             * Include total number of received items on inventory manaagement screen.
             * Added "inventory received" report with method to select prior invoice to print.
             * Corrected problem where close UPC values were being treated as equal (precision problem) when joining inventory tables.
             * Corrected DB transaction processing (added transactions for IBQryInventory2) on inventory screen.
             * Insert both UPC and PLU (not just PLU) into InvAudit.
             *** Base build 2.0.3.009
             * Allow support user to startup SysMgr (POSMain/ProcessKeyUSO() and POSOLE/CurUser()).
             * Added code to support future full inventory import (//inv4 in inventory.pas)
             * Allow dbGridOnHand to scroll anytime, but only allow scan counts to change on certain functions (//inv5 in inventory.pas)
             * Allow counts in inventory import files (//inv6 in inventory.pas).
             * Changed print header for inventory receipt report (report.pas).
             * Added report to show on hand counts by department (report.pas and inventory.pas)
             * Remove old entries in InvAudit and InvUPCScanned tables (//20051208 in CloseDay.pas)
             * Limit inventory adjustment to management users (//inv7 in inventory.pas).
             *** Base build 2.0.3.010
             * Add functionality to add single item to pending inventory receive list (inventory.pas).
             * No longer display information on PLU/UPC items not pending an inventory recieve (inventory.pas).
             * Add footer information to inventory received report (reports.pas).
             *** Base build 2.0.3.011
             * Soft code (from new DB table InvUnits) the names of units for inventory report. (PrintInventoryDeptReport() in Reports.pas)
             * Correct problem where inventory form would not load correctly when no pending receive items.  (SetUpGridOnHand() in Inventory.pas)
             * In PrintInventoryDeptReport(), soft code purchase/sale units from new DB table InvUnits. (Reports.pas)
             * In PrintInventoryDeptReport(). add footer.  (Reports.pas)
             * Correct problem in SetupOnHandGrid() where the dbGridOnHand would not correctly initilize if there
               were no pending entries to load into the grid.  (Inventory.pas)
             * Change verbage on inventory screen showing maximum breakdown item counts to reflect purchase units from database.  (Inventory.pas)
             * Add unit Encrypt for future CISP compatibility.
             *** Base build 2.0.3.013
             * Encrypt/decrypt all CISP sensitive cardholder information into/from the database (conditional compile CISP_CODE).
             * Placed temporary CISP solution (removing certain fields of ccAuth and ccBatch before exporting)
               into else clause of conditional compile CISP_CODE (was //20041209_CISP in CloseDay.pas)
             * Integrate build 2.0.1.900 OSU/ODOT phase I changes (conditional compile ODOT_VMT).
             *** Base build 2.0.4.015 - Feb. 24, 2006
             * Add pump ICON images for Fuel First cards (new PUMPICON.RES)
             * When processing PMP_AUTHORIZE message for Fuel First card, check for inside sale type (POSMAIN/FuelMessage)
             *** Base build 2.0.3.017
             * Correct for extra spaces in char() fields for encrypted fields (//20060309 in Encrypt.pas)
             * No longer add VMT Fee to sales list (//20060310)
             *** Base build 2.0.4.019
             * Change character mapping in encryption algorithm so that comma and spaces are not used.
               A comma in the encrypted text causes problems in the comma delimeted files dumped at EOD.
               (//20060418 in Encrypt.pas)
             *** Base build 2.0.4.026
             * Correct mapping of printable characters in encryption algorithm problem (//20060508 in Encrypt.pas)
             *** Base build 2.0.4.028
             * Updated logic for PDIImport.pas and PDIEx.pas
             * Check for blank strings from database to prevent exceptions during debug.  (//20060531)
             * Add checks to verify that receipt printer is active.  (//20060531b in POSPrt.pas)
             *** Base build 2.0.5.043 - May 31, 2006
             * Change to address the improper re-use of gift card track data on a transaction
               that follows a gift card balance enquiry.  (//20060602 in GiftCardBalanceInquiry())
             * Verify transaction is not a balance inquiry before verifying food stamp qualifying amounts (//20060602 in NBSCC.pas).
             * Ensure that pointer to PosiFlex control is not null.  (//20060605)
             * Change conditional compile for test void auth functionality from UNTESTED_CODE to TEST_VOID_AUTH.
             *** Base build 2.0.5.046 - June 06, 2006
             * Correct typo that cause volume to be added to amount in Snow Bird export file (//20060612 in SnowBirdEx.pas).
             *** Base build 2.0.4.049 - June 13, 2006
             * Send restriction code to credit server for manual Voyager.  (20060621b in NBSCC.pas).
             * Prepare for future code to apply gift card discounts by grade. (//20060614)
             *** Base build 2.0.5.056 - June 21, 2006
             * Print approval code on gift card balance inquiry and activation/reload receipts (//20060622)
             * Add transaction type to Buypass balance inquiry and activation/reload receipts (//20060626)
             * Add merchant ID to Buypass gift balance/activate/reload receipts.  (//20060626b)
             * Remove redundant copy of gift card information on balance inquiry receipt. (//20060626c)
             * Latest updates for PDI import/export.
             *** Base build 2.0.5.058 - June 26, 2006
             * Check for valid products on manual Voyager (//20060628 in NBSCC.pas).
             * Make labels for manual Voyager restriction code and indicated prompt fields
               visible when fields are required. (//20060628b in NBSCC.pas).
             * Correct duplication of Buypass EBT receipt line #4 as line #3 (//20060628c).
             * Print extra "debit" receipt info for EBT CB.  (//20060628d).
             * Add logic to PDIImport.pas to handle PackSize.
             *** Base build 2.0.5.061 - June 28, 2006
             * Add logic to base gift card discount by fuel grade.  (initial code added at build 056)
             *** Base build 2.0.3.062 - July 03, 2006
             * Print fuel discount information with fuel totals report.  (//20060706)
             *** Base build 2.0.3.063 - July 06, 2006
             * Added logic to support departments at PLU modifier level.  (conditional compile DEFINE PLU_MOD_DEPT)
             * Modify handling of PLU modifiers to allow selection with default.  (conditional compile DEFINE PLU_MOD_DEPT)
             * Prevent infinite loop when processing PLU modifiers.  (//20060707)
             * Correction for starting database transaction when updating totals on a cancel operation. (//20060707b)
             * Updates for PDI import.
             *** Base build 2.0.5.064 - July 07, 2006
             * Print card type name on Buypass receipts.  (//20060707c)
             *** Base build 2.0.5.065 - July 07, 2006
             * Add logic to support discounts for cash payments of fuel.  (conditional compile CASH_FUEL_DISC)
             * Change the timestamp used in the Snow Bird export filenames from the "open" date to
               the file creation date and to always encode file name as if for shift #1 / terminal #1.  (//20060712 in SnowBirdEx.pas)
             *** Base build 2.0.4.067 - July 12, 2006
             * Limit modifier selections to those defined for the PLU.  (//20060713a in procedure DisplayModifierMenu())
             * Prevent double negation on return of linked PLU items.  (//20060713b in procedure PostItemSale())
             * Address issue where modifier not identified when voiding item.  (//20060713c in procedure ProcessKeyERC())
             * Extract DeptNo of voided PLU item from sales list instead of PLU table.  (//20060713d in procedure PostItemVoid())
             * Check for redundant insert attempts of not found plu in table NFPLUExp.  (//20060713e)
             * Address issue where key pressed prior to an entry being cleared would interfere
               with subsequent keys.  (conditional compile PLU_MOD_DEPT  //20060713f in procedure ClearEntryField())
             * Re-initialize screen when sale is complete.  (conditional compile PLU_MOD_DEPT  //20060713g in procedure DisplayEntryKeyPress())
             * Update new fields in HourlyShift.  (conditional compile PLU_MOD_DEPT  //20060713h in PosPost.pas)
             * Latest updates for PDIEx.pas
             *** Base build 2.0.5.068 - July 13, 2006
             * Allow for alternate font on sales list.  (//20060714 - conditional compile SALES_LIST_FONT_COURIER)
             * Added support for PLU modifier split quanity (PDIImport.pas and //20060717a)
             * Modify PLU reports to support departments at PLU modifier level.  (//20060717b - conditional compile DEFINE PLU_MOD_DEPT)
             * Changes to support of identifying Departments at Modifier level for PDI import (PDIImport.pas)
             *** Base build 2.0.5.070 - July 17, 2006
             * Correct regression problem from build 058 causing NBS gift card balances not to print.
               (//20060718a in NBSCC.pas - extra condition added to //20060626c.)
             * Add extra logging to indicate if a drive off was from a Fuel First customer.  (//20060718b)
             *** Base build 2.0.3.071 - July 18, 2006
             * Determine department numbers for fuel grades from database.  (//20060719)
             * Update department from modifier if specified when processing PLU. (//20060720 - conditional compile PLU_MOD_DEPT)
             * Updated format of record per PDI request.  (PDIEx.pas)
             *** Base build 2.0.5.072 - July 21, 2006
             * Add support for items with more than one tax (conditional compile MULTI_TAX).
             * Add reset calls to PIN pad server.  (//20060828a)
             * Clear key value after processing key.  (//20060828b)
             * Processing of media not marked complete in all cases.  (Processing_Media not set for all exits in ProcessKeyMed() - //20060828c)
             * Check for NULL ModPacksize or PLUPackSize when exporting PDI records.  (//20060829a in PDIEx.pas)
             *** Base build 2.0.5.080 - August 30, 2006
             * Address issue where "vehicle#" and "odometer" print on certain receipts
               that should not use the values (such as voids and resumed transactions).  (//20060906c)
             * Force PAN truncation of store copy of receipt regardless of credit host.  (//20060906d)
             *** Base build 2.0.5.082 - September 06, 2006
             * After credit server changes in build 081, procedure GiftCardBalanceInquiry
               no longer needs to special case CDTSRV_BUYPASS.  (other than for different headers).  (//20060907b)
             * Address integration issue from build 072 (conditional compile MULTI_TAX) so that
               an item with only one tax will be marked on the sales list. (//20060907d )
             * Address issue from build 072 (conditional compile MULTI_TAX) where canidates
               for possible multi-tax were not being validated as PLU items.
               This change eliminate the display of a taxable flag on a
               department sale that has a department number matching a plu with multi tax records  (//20060907e)
             * Correct problem with food stamp tax reduction caluclations introduced by
               multi taxes per PLU in build 072 (conditional compile MULTI_TAX).  (//20060907f)
             * Correct problem with food stamp tax reduction caluclations for returns.  (//20060907g)
             * Print return header bold. (//20060907h)
             *** Base build 2.0.5.083 - September 07, 2006
             * Print Buypass approval code on balance inquiry receipt.  (//20060907i)
             *** Base build 2.0.5.084 - September 07, 2006
             * Force logon after import so that updated PLUs are loaded.  (//20060911a)
             * During PDI import, check for non-zero department number.  (//20060911b)
             * During PDI import, Initialize New PLU Tax number to 0 and
               use tax number of zero for multi-tax PLUs.  (//20060911c)
             * When detecting PLUs marked for deletion at end of day, also Delete any associated
               PLU modifiers and multiple tax entries of PLUs marked for deletion. (//20060911d)
             *** Base build 2.0.5.085 - September 13, 2006
             * Update the food stamp subtotal for a 'print bill' operation. (//20060913a)
             * Add support for 15-digit GTIN PLU numbers (conditinal compile GTIN_SUPPORT)
             * Add logic to automatically expand 8-digit UPC-E to 12-digit UPC-A (conditional compile UPC_EXPAND)
             *** Base build 2.0.5.090 - September 20, 2006
             * Updates to kiosk support.  (add function function ValidateUPCCheckDigit(),
               do not remove first digit of barcode,
               validate UPC check digit on 13-digit barcodes,
               check for kiosk barcodes when processing PLUs,
               no longer insert kiosk numbers in PLU table,
               label 'order' as 'barcode' on some screens and prompts)  (//20060922a)
             * Mark code that will require encryption of exception log data or backup transaction log.  (conditional compile CISP_CODE)  (//20060924)
             *** Base build 2.0.5.093 - September 25, 2006
             * (conditionally compile funciton ValidateUPCCheckDigit() with UPC_EXPAND)
             *** Base build 2.0.4.095 - Cctober 09, 2006
             * Implement a state sales tax discount for VMT transactions (conditional compile ODOT_VMT).
             *** Base build 2.0.4.096 - Cctober 11, 2006
             * Modify code marked by "//20060924" to encrypt/mask cardholder information. (//20060924a - conditional compile CISP_WIDE_FIELDS)
             * Address issue where message remains after backup and restore of database.  (//20061018c)
             * Address issue with PIN pad server after backup and restore of database.  (//20061018d)
             *** Base build 2.0.3.097 - Cctober 18, 2006
             * Activate cardholder encryption for NBS.  (conditional compile CISP_WIDE_FIELDS  //20061019a)
             *** Base build 2.0.3.100 - Cctober 19, 2006
             * Address problem from build 68 (conditional compile PLU_MOD_DEPT) and build 80
               that prevents media from being located for "change on pump" (COP) function.  (//20061023b)
             * Include "discounts" on re-prints of outside receipts.  (//20061023e)
             * Move VMT receipt data to after 'discount' and 'total' lines. (//20061023f)
             *** Base build 2.0.4.101 - Cctober 24, 2006
             *** Base build 2.0.5.102 - Cctober 25, 2006
             *** Base build 2.0.5.106 - November 06, 2006  (recompiled without conditional compile TEST_VOID_AUTH)
             * Extract Auth ID form fuel messages for stacked sales
               (so that Fuel First drive-offs of stacked sales can be recorded). (conditional compile FUEL_FIRST) (//20061107a)
             *** Base build 2.0.3.107 - November 09, 2006
             * Address issue with scanning on Metrologic scanner where prior sale is not cleared.
               (remove conditional compile PLU_MOD_DEPT from "//20060713g" change) (//20061114a)
             *** Base build 2.0.6.108 - November 14, 2006
             * Address issue where card number / expiration date field do not appear/disappear
               correctly from the credit screen following a totals request.  (//20061121b)
             *** Base build 2.0.5.111 - November 21, 2006
             * Add notification for modifier menu to help prevent unintentional scanning.  (//20061204b)
             *** Base build 2.0.5.112 - December 05, 2006
             * Remove "please respond" from modifier menu notification.  (//20061206a) (see previous change)
             * Automatically import PDI file during EOD.  (//20061207a)
             * Address issue where pole display would not quickly update after age verification.  (//20061207c)
             * Correct typo on dealing with multi-tax receipts. (no known symptom)  (//20061207d MULT_TAX should be MULTI_TAX)
             *** Base build 2.0.5.115 - December 07, 2006
             * Add support for 2-D scan of birthdates from drivers licenses.
               (//20070103a - conditional compile INSIDE_2D_SCAN - initially disabled)
             * Address issue where card swipe from PIN pad during a POS error message results
               in an application error. (//20070103b)
             * Modify report format for header showing void counts.  (//20070103c - conditional compile HUCKS_REPORTS)
             * Make cash back type differentiate between debit and EBT Cash Benefits (//20070104a)
             * Clerk notification logic added for when customer rejects total on PIN pad.  (conditional compile PRESSED_NO_NOTIFICATION)
             *** Base build 2.0.5.124 - January 05, 2007
             * Address issue where payment method (debit, EBT, etc.) not always properly identified
               for PIN pad if credit screen is displayed first.  (//20070108a)
             * Remove expiration date from receipts / POS log (//20070108b - conditional compile CISP_CODE)
             * Upgrade pump icon graphics for pump call operation.  (c:\Latitude\Resource\POSFUEL.RES)
             * Address issue where PIN pad display not updated after customer selects a cash back amount
               from 3 choices when the clerk has not yet pressed the "credit" button.  (//20070112b)
             * Address issue where food stamp purchase amount is not verified on the PIN pad. (//20070112c)
             *** Base build 2.0.5.125 - January 12, 2007
             * Address issue where payment type (debit, EBT, etc.) selected on POS screen is
               not always known in PIN pad server (resulting in PIN pad server stalling on a
               "PLEASE WAIT" prompt while cash back prompting is expected).  (//20070115a)
             * Shutdown and restart PIN pad server if it is being updated with an automaic version upgrade.  (//20070116a)
             *** Base build 2.0.5.126 - January 16, 2007
             * Added prototype logic for 7-Eleven import functionality.  (SysMgrImport.pas)
             *** Base build 2.0.6.127 - January 26, 2007
             * Do not process PLUs marked for delete.  (//20070213a)
             * For SysMgr import, clear PLU delete flag if PLU is subsequently upated.  (//20070214a)
             *** Base build 2.0.6.129 - February 14, 2007
             * Address issue where a new multiple discounts in a sale cannot be posted if the
               first occurence of the discount for the shift/terminal.  (//20070216)
             * Add support for Fuel First promotion (conditional compile FF_PROMO).
             *** Base build 2.0.6.131 - February 26, 2007
             * Add support for PDI promotions.  (conditional compile PDI_PROMOS)
             * Address PIN pad server issues after running EOD.  (//20070227a)
             * Address issue of hidden windows when POS error message issued.  (//20070227b)
             * Address exceptions thrown during EOD while debuging.  (//20070227c)
             * Removed orphaned PLUMOD records (//20070227d)
             * Do not hold unposted batches from Buypass.  (//20070227e)
             * Move CATEvents.log and CDTMsg.log to history file at EOD.  (conditional compile HUCKS_REPORTS - //20070227f)
             * Remove "store copy" from reprinted credit receipt.  (//20070227g)
             * Move decimal point on report for 'Discount as % of ...'.  (//20070227h)
             * Add food stamp tax exempt data to viewed reports.  (//20070227i)
             *** Base build 2.0.5.132 - February 27, 2007
             * Re-initialize cash drawer (if configured) whenever print server is re-connected. (//20070228a)
             *** Base build 2.0.6.133 - March 02, 2007
             *** Base build 2.0.5.134 - March 05, 2007
             * Regression problem from build 132.  'Discount as % of Total Sales' section does not print
               if conditional compile PDI_PROMO defined.  (//20070305a)
             * Remove extra line on sales display when item is voided.  (//20070305b)
             *** Base build 2.0.5.135 - March 05, 2007
             * Partial code to add verification check on Fuel First award winner. (conditional compile FF_PROMO)
             * Partially address issue where USB scaner will not operate after some operations.  (//20070307a)
             *** Base build 2.0.6.136 - March 08, 2007
             * Address issue where USB scaner will not operate after a POS error message.  (//20070307a in POSError())
             * Add support for import of volume discount pricing. (SysMgrImport.pas)
             *** Base build 2.0.6.137 - March 19, 2007
             * Add support for PDI promotions (conditional compile PDI_PROMOS)
             *** Base build 2.0.5.138 - March 20, 2007
             * Modified PDI export to produce only one promotion record per item.  (//20070320)
             *** Base build 2.0.5.140 - March 21, 2007
             * Corrected variable type issue that prevented proper comparison of values. (//20070321)
             *** Base build 2.0.5.141 - March 22, 2007
             * Add carton breakdown fields for sys mgr import function.
             * Decrypt cardholder information for Buypass host.  (//20070402a - conditional compile CISP_WIDE_FIELDS)
             * Remove conditional compile on logic that creates ccBatchEx and ccAuthEx for history file and
               also exclude PINBlock and SerialNumber from these exported database tables.
               (Original logic added at build 015)  (//20070405a)
             * Implement sysmgr import in two steps (import and activate).  (//20070405b)
             *** Base build 2.0.6.143 - April 06, 2007
             * Add acknowledgement message for "backup and restore" operation.  (//20070409b)
             * Do not allow manual backup and restore if fuel transactins active.  (//20070409c)
             * Address issue where "Activate Import" would result in I/O error.  (//20070409d)
             *** Base build 2.0.6.144 - April 10, 2007
             * Add logging for DB access issues for SysMgr PLU import.  (//20070411b)
             *** Base build 2.0.6.145 - April 11, 2007
             * Process enter button as PLU if entry present.  (//20070412a)
             * Add option to include UPC check digit.  (conditional compile INCLUDE_UPC_CHECK_DIGIT)
             * Add status messages for SysMgr Activate function.  (//20070412b)
             * Address issue where volume discount (mixmatch) would not update on import.  (//20070412c)
             *** Base build 2.0.6.146 - April 12, 2007
             *  Address issue where scanning through USB port upon entering a menu caused the
                wrong value to be processed as a price lookup.  (//20070413a)
             *** Base build 2.0.5.147 - April 16, 2007
             * Add logic for future expiration dates for mix match records.  //20070417b
             * Address issue where ccBatchEx and ccAuthEx would not populate at EOD.  //20070417c
             * Remove cardhholder name from POS log entry for media.  //20070417e
             * Update splash graphics.  (SplashSM.bmp and SplashBG.bmp in Splash.res)
             *** Base build 2.0.5.148 - April 17, 2007
             * Address issue where swipe of invalid card causes credit screen to have to be manually reset.  (//20070418a)
             * Address issue where FuelProg and CATServer could not be automatically upgraded together.  (//20070418b)
             *** Base build 2.0.5.149 - April 19, 2007
             * Address issue where double scan (from USB scanner) could inappropriately trigger the age validation form.  (//20070420a)
             * Address issue where USB scan does not work if blank area of item display is clicked.
               (//20070425a - correction to change "//20070307a" in build 137)
             *** Base build 2.0.6.151 - April 25, 2007
             * Add logic for future fuel price rollback discount feature.  (conditional compile FUEL_PRICE_ROLLBACK)
             * Add option for entering an order number or barcode number to the Kiosk entry form.  (//20070501a)
             * Address issue with CATServer application errors when restarting after an application upgrade.
               (addition to ////20070418b dealing with automatic upgade of CATServer) (//20070501b)
             *** Base build 2.0.5.153 - May 01, 2007
             * Address exception issues with setting focus on disabled fields.  (//20070509a - regression from builds 136 and 151)
             *** Base build 2.0.5.157 - May 09, 2007
             * For ESF net Buypass credit, close/restart credit server (instead of pause/resume).  (//20070515a - conditional compile ESF_NET)
             * Address lockup issue at logon when PIN pad server closes early.   (//20070515b)
             * Shorten time POS waits if credit server does not respond to EOD.  (//20070511c)
             *** Base build 2.0.5.159 - May 15, 2007
             * Combine "sys mgr" import and activate functions into one button.  (//20070515d)
             *** Base build 2.0.6.160 - May 15, 2007
             * Additional (started build 153) logic for future fuel price rollback discount feature.  (conditional compile FUEL_PRICE_ROLLBACK)
             * Address issue where prior receipts will not always load.  (//20070525b)
             * Address issue where receipt data from printing prior receipt sometimes shows up in next transaction.  (//20070529a)
             *** Base build 2.0.6.161 - May 29, 2007
             * Allow mix-match discounts of more than one quantity for the same PLU.  (//20070606a)
             *** Base build 2.0.5.162 - June 11, 2007
             * Address build 160 regression problem that prevented status message from being displayed
               for imports of volume discounts.  (//20070614a)
             * Address issue where surcharge added to credit tender of a cash-discounted fuel is not always
               added to the amount charged to the card.  (//20070615a - conditional compile FUEL_PRICE_ROLLBACK)
             * Address issue where fuel discount disqualification message is displayed mulitple times.  (//20070607b - conditional compile FUEL_PRICE_ROLLBACK)
             * Addition to change at build 162.  (//20070615c)
             * Include original timestamp on reprinted receipts.  (//20070618a)
             *** Base build 2.0.6.163 - June 19, 2007
             * Added a message when attempting to connect to Kiosk database.  (//20070621b)
             * Changed to accommodate single Item modifiers.  (//20070621c)
             *** Base build 2.0.5.164 - June 21, 2007
             * Address issue where end-of-shift reports would not run for multiple terminals.  (//20070706b)
             *** Base build 2.0.5.165 - July 06, 2007
             * Address issue where backup and restore would run on days not scheduled regardless of time of last backup. (//20070709a)
             * Ignore check digit checks on "delete" type "sys mgr" import records.  (conditional compile INCLUDE_UPC_CHECK_DIGIT)(//20070709b)
             *** Base build 2.0.6.166 - July 10, 2007
             * Address regression problem to build 163 (original timestamp on reprints) that resulted in DB exception when reprinting outside receipts
               (IBCCBatchQuery: Field 'FuelGrade' not found)  (//20070713b)
             *** Base build 2.0.6.168 - July 13, 2007
             * Added confirmation message for resetting of credit server.  (//20070717a)
             * Modify captions on Kiosk form to indicate "order" in addition to barcode.  (//20070717b and KioskForm.dfm)
             *** Base build 2.0.5.169 - July 17, 2007
             * Remove expiration date on re-printed outside receipts.  (//20070718a)
             * Include "Merchant Copy" or "Customer Copy" on receipts authorized through Buypass.  (//20070719a)
             *** Base build 2.0.5.170 - July 19, 2007
             * Address issue where SysMgr import re-generates errors from previous import.  (//200709723a)
             * Add support for mix-match (volume discount) on returns. (//20070724a)
             *** Base build 2.0.6.174 - August 08, 2007
             * Add additional support for cash fuel discount such as for split tender.  (conditional compile CASH_FUEL_DISC)
             * Delete CATEvents.log at end of day.  (//20070822b - conditional compile HUCKS_REPORTS)
             *** Base build 2.0.5.179 - August 23, 2007
             *** Base build 2.0.6.180 - August 29, 2007
             * When updating CAT or fuel servers, close CAT server through fuel server.  (//20070829a)
             * Add FuelMsg.log, DCLog.log, CATLine.log, and Pumperr.log to history file at EOD.  (//20070905c - conditional compile HUCKS_REPORTS)
             * Add logging to indicate how POS is closed.  (//20070905d)
             * Accept card swipe after PIN pad server reconnect if sale is in progress.  (//20070905e)
             *** Base build 2.0.5.181 - September 07, 2007
             * Address issue where concurrent POS error messages lock up register
               and log POS errors in electronic journal.  (//20070910b)
             * Correct typo in build 181 change (//20070905d) (//20070905dd)
             *** Base build 2.0.5.182 - September 10, 2007
             * Move ImportErr.log, ImportChg.log and PBDNLD to history file at EOD.  (conditional compile HUCKS_REPORTS - //20070924a)
             * [Souce code management: Divide functionalty of unit Encrypt into different units.] (//20070920b)
             *** Base build 2.0.5.184 - September 24, 2007
             * Add logging for failed attempts to open database.  (//20070925a)
             * Add notifications for logon failures.  (//20070925b)
             * Address issues with entering birth date for suspend/resume sales.  (//20070926a)
             * [Souce code management: Move user logon code from POSMain to POSUser.] (//20070926b)
             * Reset PIN pad server when reconnecting to it.  (//20070926c)
             * Address issue where memo logged to POSLog would not fit in DB field.  (//20070926d)
             *** Base build 2.0.5.186 - September 27, 2007
             * [Additional changes for importing departments in SysMgrImport (//20070928a)]
             * Address issue where gift card purchases are not reported correctly unless the name for the card type
               in the database is set to 'P1'.  (//20071003a)
             * Cleanup "Host Totals..." labels that are either used for local totals or are redundant labels.  (//20071004b)
             * Address issue where Sys Mgr import status screen remains displayed after import completes.  (//20071005b)
             *** Base build 2.0.5.187 - October 09, 2007
             * Address register lockup due to timer activity. (//20071018b)
             *** Base build 2.0.5.188 - October 18, 2007
             * Address issue where drive-off media is not correctly defined in the database.  (//20071019a)
             * Left out change from build 188(//20071019b)
             *** Base build 2.0.5.189 - October 19, 2007
             * Add fuel first card number to receipt.  (conditional compile $IFDEF FUEL_FIRST)  (//20071023a)
             * Addition to build 168 change (correction for adding original timestamp to reprinted receipts) (//20071023b)
             * New logic for updating kiosk prices.  (conditional compile DEV_TEST) (//20071018a)
             * Modify method used to generate backup database filenames.  (//20071018b)
             * Prevent access to DB to update flowing pump icons on a logged out register (can cause problems during backup and restore).  (//20071023c)
             * Change pole display message to "closed" if waiting to log in. (//20071023d)
             *** Base build 2.0.5.190 - October 19, 2007
             *** Base build 2.0.6.191 - October 26, 2007
             * Add support for partial authorizations (such as from VISA or MasterCard gift cards with depleted balances).  (//20071029a)
             * Process balance information when provided for VISA or MasterCard gift cards.  (//20071029b)
             *** Base build 2.0.6.192 - November 02, 2007
             * Address issue where multiple PIN pad servers were left running.  (//20071107a)
             * Address issue where CAT server does not always close when being automatically updated.  (//20071107b)
             * Address terminal locking issue when card is swiped at PIN pad.  (//20071107c)
             * Adjust where reports cut page at request of Huck's Data Analysts.  (conditional compile HUCKS_REPORTS)  (//20071107d)
             * Activate code to update kiosk prices.  (had been conditionally compiled with DEV_TEST)
             * [code management - move code from unit PDIImport to POSMain] (//20071107f)
             * Add trickle feed of sales data to DAX system.  (conditional compile DAX_SUPPORT)(//20071108a)
             *** Base build 2.0.5.197 - November 07, 2007
             * Add functionality to update departments with SysMgr import (//20071109a)
             *** Base build 2.0.6.198 - November 09, 2007
             * Address lockups during end of shift.  (//20071113d)
             * Address issue where printer would be left paused after printing a totals report.  (//20071113e)
             * Address issue where "cancel" key is ignored while waiting for a Buypass totals request.  (//20071113f)
             * Increase size allowed in fleet card vehicle numbers from 5 to 6 digits.  (//20071114a)
             * Address issue where gift card activation and fuel pre-pay cannot be in the same sales transaction. (//20071116a)
             * Address issue where message 'Error Voiding Gift Card...Collect for Store Manager' does not clear.    (//20071116b)
             *** Base build 2.0.5.199 - November 19, 2007
             * Address issue where item could not be void if item item(s) above have previously be voided.(//20071119c)
             * Address issue where an automatically voided gift card would not display as voided on sales list (but it would on the receipt). (//20071119d)
             * Address issue where gift card recharged amounts would void even when the card was never charged. (//20071119e)
             *** Base build 2.0.5.200 - November 20, 2007
             * Address issue where error correct does not process the correct sales list entry.  (//20071120a)
             * Add error logging for SysMgr import PLU records with missing requrired fields.  (//20071127a)
             * Allow SysMgr import to update/insert PLU records without a UPC value.  (//20071127b)
             * Add configuration parameter in DB for DAX store ID (conditional compile DAX_SUPPORT) (//20071128a)
             * Use 3-digit store numbers for DAX processing (conditional compile DAX_SUPPORT) (//20071128b)
             * Save DAX data per transaction instead of at EOD. (conditional compile DAX_SUPPORT) (//20071128c)
             * Delete old DAX history files at EOD. (conditional compile DAX_SUPPORT) (//20071128d)
             * Add DAX files (current and previous day) to EOD history files (also reformat file names). (conditional compile DAX_SUPPORT) (//20071128e)
             *** Base build 2.0.6.201 - November 30, 2007
             *** Base build 2.0.5.202 - December 03, 2007
             * Add columns for SKUCode, UseStoreEDICode, and TransPrice to DAX export file. (conditional compile DAX_SUPPORT)  (//20071211a)
             * Do not send header record with DAX trickle feed.  (conditional compile DAX_SUPPORT)  (//20071211b)
             *** Base build 2.0.6.203 - December 11, 2007
             * Regression problem in build 203 (causing error message "DAX Support not properly configured. Disabling for terminal.").  (//20071212a)
             *** Base build 2.0.6.204 - December 12, 2007
             * Change line termination for DAX trickle feed from CR to CR-LF.  (conditional compile DAX_SUPPORT) (//20071213a)
             *** Base build 2.0.6.205 - December 13, 2007
             * [code management - move definition of TPumpIcon from POSTools to TPumpxIcon in local unit PumpxIcon.]  (//20080102a)
             * Address build 201 regression issue where wrong (or no) item error corrected after
               another item has been error corrected.  (//20080102b)
             *** Base build 2.0.6.206 - January 03, 2008
             * Modify method used to create graphics on pump icon.  (conditional compile PUMP_ICON_EXT) (Use one set of graphics for all pumps - //20080107)
             * Address issue where CAT help button does not generate sound inside (regression problem in build 206). (//20080109a)
             * Remove Perficient, Inc. logo from startup graphics. (SplashSM.bmp and SplashBG.bmp in c:\Resource\Splash.res)
             *** Base build 2.0.6.207 - January 11, 2008
             * Remove logic to verify Fuel First card number on promotion winner.  (conditional compile FF_PROMO changed to FF_PROMO_20080128 on logic that applies)
             * New logic fo FF promotions (conditinoal compile FF_PROMO - //20080128a)  (//20080207b)
             * Include pump number on inside printed fuel receipts (ccRecpt/PrintCardReceipt() & FuelRcpt/PrintFuelReceipt()).
             * Change SQL that modifies export files for CISP compliance so that EOD will run faster.
             * Add ReportFtr to credit card batch report to allow printer to un-pause during EOD
             * Address issue where QTY activation of gift cards results in the last 4 digits of the first card number repeating on the display list.
             * Add activation interface to IDT.
             * Print extra receipt (for store) if product that fail to activate.
             * Change method to identify voided activation product so that the credit server can determine if original activation were sent.
             * Add configuration parameter for dollar limit to print credit signature lines on receipts.  (//20081017a)
             * Restrict media used to purchase money orders.
             * Add verification for re-swipe of the same activation product during the same transaction.  (20081112)
             * Reset fail-safe timeout for activation products whenever a status message is received.  (20081119)
             * Add EOD report to show activation products that failed to activate.  (20081209)
             * Include PIN (if available) on receipts for void activations.  (20081222).
             * Activate products after final tender.  (20090130)
             * When activation products are auto-voided after tender, place new voided lines on sales list prior to media lines.  (20090316)
             * move some Activate response handling to main thread. (20090319)
             * Regression - error correct button on IDT product does not work. (20090319)
             * Do not try to reverse a return of an auto error corrected activation product.  (20090326)
             * Process activation product returns before tender (continue to process activations post tender).  (20090327)
             * Export new tables that breakout fuel vs. non fuel and sales tax for credit transactions.  (20090202)
             * Address issue where inside authorization is sometimes incorrectly labeled as fuel-first.  (20090505)
             * Add support for Ingenico Pin Pad.  (20090515)
             * Re-boot pin pad after downloading files, copy files to other registers and delete after downloading.  20090515
             * Wait for signature on Pin pad before finalizing sales transaction and implement signature limit at pin pad.  (20090515)
             * Rejecting amount at pin pad leaves pin pad unusable for rest of transaction (unless sales amount due is updated).  (20090619)
             * Handle return transactions on pin pad.  (20090615)
             * Address issue where initial sales item(s) of transaction may not be displayed on pin pad.  (20090625)
             * Redisplay sales list on pin pad for resumed sale.  (20090515)
             * Pin pad changes to allow for EBT cards.  (20090806)

  Purpose:   Main POS thread
-----------------------------------------------------------------------------}
unit POSMain;
{$I ConditionalCompileSymbols.txt}
interface
uses

  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, FileCtrl,
  StdCtrls, ExtCtrls, ComCtrls, AdPort, DB, DBTables, Buttons, ComObj, ShellAPI,
  CloseDay, Math, ooMisc, PumpxIcon, FuelProg_TLB,  //...20080102a
  //ADSCrdtSrvr_TLB, NBSCrdtSrvr_TLB, BuypassCrdtSrvr_TLB,
  ReceiptSrvr_TLB, POSBtn, DBInt,
  MMSystem, OleCtrls, Registry, POSListBox, AbArcTyp, AbZBrows, AbZipper,
  AbBase, AbBrowse, IBServices, TrayIcon, Menus, IBQuery,
  Keyboard, POSMisc, RXCtrls, //CarWashSrvr_TLB,
  SyncObjs, ReceiptSrvrEvents, //CarWashSrvrEvents,
  Carwash_TLB,
  PINPadTrans, PinPadStatus,
  IdTCPClient, TagTCPClient, Indicator,
  OposScanner_1_5_Lib_TLB, OposMSR_1_5_Lib_TLB,
  POSILib_MSR_TLB, CarwashEvents, MOInq, PosThreads, Scanner, MSR, LatTypes, LatTaxes, PumpLockMgr,
  Gauges, hScales;
  //Gift

const
  {$I ExportTags.INC}
  {$I FuelMsgTags.INC}
  {$I PumpStateTags.INC}
  {$I CreditServerConst.INC}
  {$I CreditMsgTags.INC}
  {$I MOTags.inc}
  {$I MCPTags.inc}
  {$I CarWashServerConst.INC}
  {$I Pinpad.inc}
  {$I OPOS.Inc}

  {$IFDEF DEV_PIN_PAD}
  CreditPromptFlags : word = PINPAD_PROMPT_NONE;
  {$ENDIF}
  //53l...
  bPOSGetVehicleNo : boolean = false;
  bPOSGetZipCode  : boolean = false;
  //...53l
  //dma...
  bPOSDebitBINMngt : boolean = false;
  //...dam
  bPOSGetDriverID : boolean = false;
  bPOSGetOdometer : boolean = false;
  bPOSGetRefNo    : boolean = false;
  //53l...
  bPOSGotVehicleNo : boolean = false;
  bPOSGotZipCode  : boolean = false;
  //...53l
  bPOSGotDriverID : boolean = false;
  bPOSGotOdometer : boolean = false;
  bPOSGotRefNo    : boolean = False;


  // (moved to CreditServerConst.inc) DB_VERSION_ID_MIX_MATCH_EXP_DATE  = 115200;  //20070417b
  // (moved to CreditServerConst.inc) DB_VERSION_ID_MEDIA_FUEL_DISCOUNT = 115300;
  //DB_VERSION_ID_DAX = 116300;       //20071128a

  // Add one of the first two with one of the latter 7 to get the button you want
  BTN_RND     = 0;
  BTN_SQR     = 7;
  BTN_BLUE    = 1;
  BTN_GREEN   = 2;
  BTN_RED     = 3;
  BTN_WHITE   = 4;
  BTN_MAGENTA = 5;
  BTN_CYAN    = 6;
  BTN_YELLOW  = 7;

  CO_DEFAULT = CO_NO;  // default cashout option for gift cards.
  CASH_MEDIA_TYPE = 1;
  CHECK_MEDIA_TYPE = 2;
  CREDIT_MEDIA_TYPE = 3;
  DEBIT_MEDIA_TYPE = 4;
  COUPON_MEDIA_TYPE = 5;
  FOOD_STAMP_MEDIA_TYPE = 6;
  DEFAULT_GIFT_CARD_MEDIA_TYPE = 7;
  EBT_FS_MEDIA_TYPE = 8;
  EBT_CB_MEDIA_TYPE = 9;
  CASH_MEDIA_NUMBER : byte = 1;
  CHECK_MEDIA_NUMBER : byte = 2;
  CREDIT_MEDIA_NUMBER : byte = 3;
  DEBIT_MEDIA_NUMBER : byte = 4;
  COUPON_MEDIA_NUMBER : byte = 5;
  FOOD_STAMP_MEDIA_NUMBER : byte = 6;
//20071019a  {$IFDEF FUEL_FIRST}
  DRIVE_OFF_MEDIA_NUMBER : byte = 6;      // (todo) Resolve media number conflicts.
//20071019a  {$ENDIF}
  DEFAULT_GIFT_CARD_MEDIA_NUMBER : byte = 7;
  EBT_FS_MEDIA_NUMBER : byte = 8;
  EBT_CB_MEDIA_NUMBER : byte = 9;
  EMPLOYEE_CHARGE_MEDIA_NUMBER = 10;
  NULL_MEDIA_NUMBER : byte = 127; // Used to complete tender after activation voids when change is due.
  //...53o
  MAX_NUM_RESTRICTION_CODES = 100;  // Used for modulo arithmetic on department restriction codes
                                    // to segregrate "giftcard" vs. "product" restrictions.
  // Following are constants used to denote different POS clients (such as when another
  // sale is processed after the "next customer" button is pressed.
  NUM_CREDIT_CLIENTS = 1;  // Number of concurrent clients supported.
  NORM_CREDIT_CLIENT = 0;  // Index of data structure for "normal" (i.e., not next customer) client.
  NUM_CARWASH_CLIENTS = 1;  // Number of concurrent clients supported.
  NORM_CARWASH_CLIENT = 0;  // Index of data structure for "normal" (i.e., not next customer) client.
  TRANSNO_NONE            = -1;
                            // (todo) Following needs to be an invalid transaction number.
//20031208 (moved to CreditServerConst.inc)  TRANSNO_BALANCE_INQUIRY = 70707;  // Fake transaction number to use for gift card balance inquiries.
  //TRANSNO_GIFT_PURCHASE   = -2;  // Fake transaction number to use when swiping new gift cards
                                 //   to be activated.

  NOAMOUNT    = 0;
  NOSALEID    = 0;
  NOTRANSNO   = 0;
  NODESTPUMP  = 0;

  FUELSRV_SIM           = 1;
  FUELSRV_PROGRESSIVE   = 2;
  FUELSRV_ALLIED        = 3;

  VAL_PROMPTDATE = 0;
  VAL_ENTERDATE  = 1;
  VAL_DATEOPTION = 2;


  MaxPumps = 32;

  MAX_GRADE_NUMBER = 5;

  STARTINGTILL_NOTUSED  = 1;
  STARTINGTILL_DEFAULT  = 2;
  STARTINGTILL_ENTER  = 3;

  // Following is used to determine when message window is for card activation.
  POS_ERROR_MSG_TAG_CARD_ACTIVATION = 181;  // any unique value to ID message.
  // Following defines a fail-safe wait time for the credit server to respond to activation requests.
  PRODUCT_ACTIVATION_TIMEOUT_DELTA = 15.0 {seconds} / 86400.0 {seconds/day};

  WM_CHECKKEY             = WM_USER + 100;
  WM_PREPROCESSKEY        = WM_USER + 101;
  WM_CONNECTFUEL          = WM_USER + 102;
  WM_FUELMSG              = WM_USER + 103;
  WM_CONNECTCREDIT        = WM_USER + 104;
  WM_CREDITMSG            = WM_USER + 105;

  WM_SHOWPUMPINFO         = WM_USER + 107;
  WM_RECEIPTERRORMSG      = WM_USER + 108;
  WM_COPMSG               = WM_USER + 110;
  WM_SELECTFUELSALE       = WM_USER + 111;
  WM_PROCESSFUEL          = WM_USER + 112;
  WM_PROCESSPREPAYREFUND  = WM_USER + 113;
  WM_PROCESSPREPAY        = WM_USER + 114;
  WM_POSTPREPAY           = WM_USER + 115;
  WM_FIRSTLOGON           = WM_USER + 116;
  WM_BACKUP               = WM_USER + 117;
  WM_CARWASH_MSG          = WM_USER + 120;
  WM_UPDATEPINPAD         = WM_USER + 130;
  WM_COMPLETELOGON        = WM_USER + 135;

  WM_FSMSG                = WM_USER + 140;
  WM_CCMSG                = WM_USER + 150;
  WM_MOMSG                = WM_USER + 151;
  WM_MOMSGPRINT           = WM_USER + 152;
  WM_OUTFSMSG             = WM_USER + 160;

  //20050228
  WM_SCANNED_PLU          = WM_USER + 170;
  WM_SCANNED_KSL          = WM_USER + 180;
  //20050228
  WM_ACTIVATION           = WM_USER + 181;
  WM_ACTIVATION_RESPONDED = WM_USER + 183;  // Message sent when activation response received from credit server.
  //WM_PIN_PAD_DEV_RESP     = WM_USER + 184;  // Message sent when response received from pin pad device.

  WM_KILLPOS = WM_USER + 999;


{$IFNDEF PUMP_ICON_EXT} //... - (SOUND_* constant definitions moved to PumpStateTags.inc - 20080104)
  SOUND_CALL = 1;
  SOUND_COLLECT = 2;
  SOUND_DRIVEOFF = 3;
{$ENDIF}

  MM_SPLIT = 1;
  MM_COMBO = 2;

  MM_NONE     = -1;
  MM_VENDOR   = 1;
  MM_DEPT     = 2;
  MM_PLU      = 3;
  MM_PRODGRP  = 4;
  MM_MODIFIER = 5;

  //Gift
  // Values for CreditAuthToken
  CA_BUILD_AUTH              =   1;
  CA_BUILD_COLLECT           =  30;
  //53g...
  CA_BUILD_CHECK_AUTH        =  60;
  //...53g
//bp...
  CA_BUILD_TOTALS            =  80;
  CA_BUILD_VOID_CREDIT       =  90;
//...bp
  CA_HANDLE_RESPONSE         = 100;
  CA_HANDLE_TIMEOUT          = 126;
  CA_IDLE                    = 999;
  // Values for fmNBSCCForm.GiftCardUsage //
  GC_NONE     = 10;  // Normal usage (not for new gift card purchase/activation/balance inquiry)
  GC_PURCHASE = 11;  // Used to get infomation swiped from a new card at purchase time.
  GC_ACTIVATE = 12;  // Used to activate a new gift card.
  GC_BALANCE  = 13;  // Used for balance inquiry of gift card.
  GC_TOTALS   = 14;  // Used for Buypass totals request.
  GC_VOID_CREDIT = 15;  // Used to reverse a previous credit purchase.
  GC_VOID_DEBIT = 16;  // Used to reverse a previous debit purchase.
  //53g...
  GC_CHECK    = 17;  // Use for check authorizations through the credit server
  //...53g
  GC_VERIFY_FUEL_FIRST = 18;  // FF_PROMO

  // Values for gift card status
  CS_JUST_RECHARGED = -2;
  CS_JUST_ACTIVATED = -1;
  CS_UNKNOWN        =  0;
  CS_INACTIVE       =  1;
  CS_DEPLETED       =  2;
  CS_STILL_ACTIVE   =  3;
  bGiftCardReceiptInfoFollows : boolean = False;  // To prevent auto-cut prior to balance info.
  //Gift

  //cwa...
  // Values for CarwashInterfaceState
  CI_IDLE                    =   1;
  CI_BUILD_CODE_REQUEST      =  11;
  CI_BUILD_PRICE_LOAD        =  12;
  CI_BUILD_PRICE_STORE       =  13;
  CI_HANDLE_RESPONSE         =  21;
  CI_HANDLE_TIMEOUT          =  31;

  CI_FAILSAFE_TIMEOUT        = 15000 {msecs};  // MAX time to wait for response from carwash hardware.
  //...cwa

  NO_PUMPS           : Integer = 8;

  bClosingPOS        : Boolean = False;

  POST_PRINT         : Boolean = True;
  PRINT_ON_REQUEST   : Boolean = False;
  PRINT_OLD_RECEIPT  : Boolean = False;

  PRINTING_REPORT    : Boolean = False;
  LAST_REPORT        : Boolean = True;

  CATSERVERRUNNING   : Boolean = True;

  Call_Beeper        : Integer = 0;
  bErrorDisplayOn    : Boolean = False;
  Error_SkipKey      : Boolean = False;
  BadCardSwipes      : Byte    = 0;
  BadCardRead        : Boolean = False;
  //Gift converted to a property Processing_Media   : Boolean = False;
  { User security }
  SkipPassCheck    : Boolean = False;
  Security_Active  : Boolean = True;
  CurrentUserID    : String  = '';
  CurrentUser      : String  = '';
  { 3rd Pary Interfaces }
  EOSExports       : Boolean = False;
  EODExports       : Boolean = False;
  EODExportPath    : String  = '';
  FuelPriceImport  : Boolean = False;
  FuelPricePath    : String  = '';

  DAYCLOSEInProgress : Boolean = False;
  EODInProgress : Boolean = False;
  EOSInProgress : Boolean = False;

{$IFNDEF PUMP_ICON_EXT}  //... - (FR_* constant definitions moved to PumpStateTags.inc - 20080104)
  FR_MAX = 66;
  FR_IDLENOCAT     = 0;
  FR_UPSTART       = 1;
  FR_UPEND         = 6;
  FR_FLOWSTART     = 7;
  FR_FLOWEND       = 8;
  FR_PAY           = 9 ;
  FR_WARNSTART     = 9;
  FR_WARNEND       = 10;
  FR_DRIVEOFF      = 10;
  FR_STOP          = 11;
  FR_HELP          = 12;
  FR_VISA          = 13;
  FR_AUTHORIZED    = 14;
  FR_COMMDOWN      = 15;
  FR_RESERVED      = 16;
  FR_IDLECATOFF    = 17;
  FR_IDLECATON     = 18;
  FR_VISAAUTH      = 19;
  FR_MC            = 20;      //madhu gv  remove  15/12/2017
  FR_MCAUTH        = 21;
  FR_DISC          = 22;
  FR_DISCAUTH      = 23;
  FR_AMEX          = 24;
  FR_AMEXAUTH      = 25;
  FR_FLEETONE      = 26;
  FR_FLEETONEAUTH  = 27;
  FR_VOYAGER       = 28;
  FR_VOYAGERAUTH   = 29;
  FR_WEX           = 30;
  FR_WEXAUTH       = 31;
  //Gift
  FR_GIFT          = 32;
  FR_GIFTAUTH      = 33;
  FR_VISAWAIT      = 34;
  FR_MCWAIT        = 35;
  FR_DISCWAIT      = 36;
  FR_AMEXWAIT      = 37;
  FR_FLEETONEWAIT  = 38;
  FR_VOYAGERWAIT   = 39;
  FR_WEXWAIT       = 40;
  FR_GIFTWAIT      = 41;

  FR_VISAFAIL      = 42;
  FR_MCFAIL        = 43;
  FR_DISCFAIL      = 44;
  FR_AMEXFAIL      = 45;
  FR_FLEETONEFAIL  = 46;
  FR_VOYAGERFAIL   = 47;
  FR_WEXFAIL       = 48;
  FR_GIFTFAIL      = 49;
  FR_DINERS        = 50;
  FR_DINERSAUTH    = 51;
  FR_FLOWSTARTUNL  = 52;
  FR_FLOWENDUNL    = 53;
  FR_FLOWSTARTPLU  = 54;
  FR_FLOWENDPLU    = 55;
  FR_FLOWSTARTSUP  = 56;
  FR_FLOWENDSUP    = 57;
  FR_FLOWSTARTDIE  = 58;
  FR_FLOWENDDIE    = 59;
  FR_FLOWSTARTKER  = 60;
  FR_FLOWENDKER    = 61;
  {$IFDEF FUEL_FIRST}
  FR_FUELFIRST     = 62;
  FR_FUELFIRSTAUTH = 63;
  FR_FUELFIRSTWAIT = 64;
  FR_FUELFIRSTFAIL = 65;
  {$ENDIF}
  {$IFDEF FF_PROMO}
  FR_FUELFIRST_AUTH_WIN     = 64;  // (todo) change to 66 once new frames available
  FR_FLOWSTARTFUELFIRST     = 58;  // (todo) change to 67 once new frames available
  FR_FLOWENDFUELFIRST       = 59;  // (todo) change to 68 once new frames available
  FR_FLOWSTARTFUELFIRST_WIN = 60;  // (todo) change to 69 once new frames available
  FR_FLOWENDFUELFIRST_WIN   = 61;  // (todo) change to 70 once new frames available
  FR_PAY_FUELFIRST          =  9;  // (todo) change to 71 once new frames available
  FR_PAY_FUELFIRST_WIN      = 10;  // (todo) change to 72 once new frames available
  {$ENDIF}
{$ENDIF}  //... not PUMP_ICON_EXT
  //Build 17
  Icons_Per_Line = 10;

  PINPADPROMPT_IDLE         : string = 'Idle';
  PINPADPROMPT_CLOSED       : string = 'Terminal Closed ';
  PINPADPROMPT_VEHICLEID    : string = 'Vehicle ID';
  PINPADPROMPT_DRIVERID     : string = 'Driver ID';
  PINPADPROMPT_ODOMETER     : string = 'Odometer';
  PINPADPROMPT_REFNO        : string = 'Reference No';
  PINPADPROMPT_SWIPECARD    : string = 'Swipe Card';
  PINPADPROMPT_ENTERPIN     : string = 'Enter PIN';
  PINPADPROMPT_CASHBACK     : string = 'Cash Back?      YES          NO';
  PINPADPROMPT_ENTERAMOUNT  : string = 'Enter Amount';
  PINPADPROMPT_PLEASEWAIT   : string = '  Please Wait';
  PINPADPROMPT_AUTHORIZING  : string = 'Authorizing     Please Wait';
  PINPADPROMPT_THANKYOU     : string = '   Thank You!';
  PINPADPROMPT_SELECTPAYMENT1: string = 'Debit     Credit';
  PINPADPROMPT_SELECTPAYMENT2: string = 'Debit GFT Credit';
  //53l...
  PINPADPROMPT_ZIP          : string = 'Enter Zip Code';
  //...53l

  (* //dma... (moved to PINPadconst.inc)
  NOPINPADPROMPT_IDLE         = 1;
  NOPINPADPROMPT_CLOSED       = 2;
  NOPINPADPROMPT_VEHICLEID    = 3;
  NOPINPADPROMPT_DRIVERID     = 4;
  NOPINPADPROMPT_ODOMETER     = 5;
  NOPINPADPROMPT_REFNO        = 6;
  NOPINPADPROMPT_SWIPECARD    = 7;
  NOPINPADPROMPT_ENTERPIN     = 8;
  NOPINPADPROMPT_CASHBACK     = 9;
  NOPINPADPROMPT_ENTERAMOUNT  = 10;
  NOPINPADPROMPT_PLEASEWAIT   = 11;
  NOPINPADPROMPT_AUTHORIZING  = 12;
  NOPINPADPROMPT_THANKYOU     = 13;
  NOPINPADPROMPT_SELECTPAYMENT1 = 14;
  NOPINPADPROMPT_SELECTPAYMENT2 = 15;
  //53l...
  NOPINPADPROMPT_ZIP          = 16;
  //...53l
  *)

  DRIVEOFFSOUND              = 0;
  RESPONSESOUND              = 1;
  VALIDATEAGESOUND           = 2;
  ENTERDATESOUND             = 3;
  CATHELPSOUND               = 4;

  {$IFDEF CASH_FUEL_DISC}
  CASH_FUEL_DISC_NO = 2000;                                                     // (was 97)
  {$ENDIF}
// (moved to PumpStateTags.INC)  CASH_EQUIV_FUEL_DISC_NO = 1000;

  {$IFDEF PDI_PROMOS}
  //Added for Promotion Discount types
  C_FIXED_PRICE       =  'Fix Price';
  C_DISC_PERCENT      =  'Disc Prcnt';
  C_DISC_AMOUNT       =  'Disc Amt';
  //Added for Promotion Item List Types
  C_ITEMLIST_TYPE_ITEM = 'ITEM';
  C_ITEMLIST_TYPE_DEPT = 'DEPT';
  {$ENDIF}

  SU_LOOP_WAIT = 1000;

  bPANTruncationStoreCopy      = True;
  bPANTruncationCustomerCopy   = True;
  nPANNonTruncatedStoreCopy    = 4;
  nPANNonTruncatedCustomerCopy = 4;

type
  //Gift

  pRestrictedDept = ^TRestrictedDept;
  TRestrictedDept = record
    DeptNo          : integer;
    RestrictionCode : integer;
  end;

  pCreditClient = ^TCreditClient;
  TCreditClient = record
    CreditTransNo        : integer;
    ActivateTransNo      : integer;
    //20020205...
    bCreditAuthFailed    : boolean;
    //...20020205
    GiftCardUsedList     : TList;
    GiftCardActivateList : TList;
    RestrictSalesTaxList : Tlist;
  end;
  //Gift
  //cwa...
  pCarwashClient = ^TCarwashClient;
  TCarwashClient = record
    CarwashTransNo        : integer;
    CWAccessType          : integer;
  end;
  //...cwa

  pReceiptErrorMsg = ^TReceiptErrorMsg;
  TReceiptErrorMsg = record
    Text : string;
  end;

  TWMReceiptErrorMsg = record
    Msg: Cardinal;
    Detail : pReceiptErrorMsg;
    ReceiptErrorMsg : pReceiptErrorMsg;
    Result : LongInt;
  end;

  pStatusMsg = ^TStatusMsg;
  TStatusMsg = record
    Text : string;
  end;

  TWMStatus = record
    Msg: Cardinal;
    MsgType : Integer;
    Status  : pStatusMsg;
    Result  : LongInt;
  end;

  pCOPMsg = ^TCOPMsg;
  TCOPMsg = record
    PumpNo : integer;
    PrePayAmount : currency;
  end;

  TWMCOP = record
    Msg     : Cardinal;
    MsgType : Integer;
    COPInfo  : pCOPMsg;
    Result  : LongInt;
  end;

  pProcessFuelMsg = ^TProcessFuelMsg;
  TProcessFuelMsg = record
    PumpNo     : integer;
    HoseNo     : integer;
    SaleID     : integer;
    UnitPrice  : currency;
    SaleVolume : currency;
    SaleAmount : currency;
    {$IFDEF FUEL_FIRST}
    AuthID     : integer;
    CardType   : integer;
    {$ENDIF}
    {$IFDEF ODOT_VMT}
    VMTFee     : currency;
    VMTReceiptData : WideString;
    {$ENDIF}
  end;

  TWMProcessFuel = record
    Msg     : Cardinal;
    MsgType : Integer;
    ProcessFuelInfo  : pProcessFuelMsg;
    Result  : LongInt;
  end;

  pProcessPrePayMsg = ^TProcessPrePayMsg;
  TProcessPrePayMsg = record
    PumpNo     : integer;
    PrePayAmount : currency;
  end;

  TWMProcessPrePay = record
    Msg     : Cardinal;
    MsgType : Integer;
    ProcessPrePayInfo  : pProcessPrePayMsg;
    Result  : LongInt;
  end;

  pProcessPrePayRefundMsg = ^TProcessPrePayRefundMsg;
  TProcessPrePayRefundMsg = record
    PumpNo     : integer;
    SaleID     : integer;
    RefundAmount : currency;
  end;

  TWMProcessPrePayRefund = record
    Msg     : Cardinal;
    MsgType : Integer;
    ProcessPrePayRefundInfo  : pProcessPrePayRefundMsg;
    Result  : LongInt;
  end;


  pPostPrePayMsg = ^TPostPrePayMsg;
  TPostPrePayMsg = record
    PumpNo       : integer;
    HoseNo       : integer;
    SaleID       : integer;
    SaleVolume   : currency;
    SaleAmount   : currency;
    PrePayAmount : currency;
  end;

  TWMPostPrePay = record
    Msg     : Cardinal;
    MsgType : Integer;
    PostPrePayInfo  : pPostPrePayMsg;
    Result  : LongInt;
  end;

  {$IFDEF FUEL_FIRST}
  pPumpCATInfo = ^TPumpCATInfo;
  TPumpCATInfo = record
    AuthID        : integer;
  end;
  {$ENDIF}

  PFuelInfo = ^TFuelInfo;
  TFuelInfo = record
    PumpNo       : short;
    PumpAction   : short;
    PumpSaleNo   : short;
    PumpError    : short;
    PumpErrorMsg : string;
    PumpTotalID  : integer;
    TerminalNo   : integer;
    SaleID       : integer;
    //Gift
    AuthID       : integer;
    //Gift
    {$IFDEF FUEL_FIRST}  //20061107a
    PumpSale1CardTypeNo   : integer;
    PumpSale2CardTypeNo   : integer;
    PumpSale1AuthID       : integer;
    PumpSale2AuthID       : integer;
    {$ENDIF}

    PumpSale1Status       : byte;
    PumpSale1Hose         : byte;
    PumpSale1Type         : byte;
    PumpSale1Amount       : currency;
    PumpSale1PrePayAmount : currency;
    PumpSale1PresetAmount : currency;
    PumpSale1Volume       : currency;
    PumpSale1UnitPrice    : currency;
    PumpSale1ID           : integer;
    PumpSale1CollectTime  : TDateTime;
    {$IFDEF ODOT_VMT}
    PumpSale1VMTFee       : currency;
    PumpSale1VMTReceiptData : WideString;
    {$ENDIF}

    PumpSale2Status       : byte;
    PumpSale2Hose         : byte;
    PumpSale2Type         : byte;
    PumpSale2Amount       : currency;
    PumpSale2PrePayAmount : currency;
    PumpSale2Volume       : currency;
    PumpSale2UnitPrice    : currency;
    PumpSale2ID           : integer;
    PumpSale2CollectTime  : TDateTime;
    {$IFDEF ODOT_VMT}
    PumpSale2VMTFee       : currency;
    PumpSale2VMTReceiptData : WideString;
    {$ENDIF}

    PrinterError          : boolean;
    PrinterPaperLow       : boolean;
    PrinterPaperOut       : boolean;
    CATOnLine             : boolean;
    CATEnabled            : boolean;


  end;

  TWMFuel = record
    Msg: Cardinal;
    UnUsed : Integer;
    FuelInfo : PFuelInfo;
    Result : LongInt;
  end;

  TWMCATMsg = record
    Msg      : Cardinal;
    Reader   : Word;
    MsgCode  : Longint;
    Result   : Longint;
  end;

  TWMPOSKey = record
    Msg: Cardinal;
    KeyCode  : char;
    Blank    : char;
    KeyBuff  : Longint;
    Result   : LongInt;
  end;

  pPopUpMsg = ^TPopUpMsg;
  TPopUpMsg = record
    MsgType       : Integer;  // 1 = eos 2 = eod 3 = user 4 = daily
    MsgTime       : TTime;
    MsgUserID     : string[10];
    MsgHeader     : string[30];
    MsgLine       : array[1..10] of string[50];
  end;

//bp...
  pHostTotals = ^THostTotals;
  THostTotals = record
    DayID      : integer;    // key field for DB table ccHostTotals
    BatchID    : integer;    // key field for DB table ccHostTotals
    CreateDate : TDateTime;
    GrandTotal : currency;   // All cards (excludes "AO", "SV1", "SV3", and "SV4")
    FeeAmount  : currency;
    NetAmount  : currency;
    CCCount    : integer;    // Credit card (other than accumulated elsewhere)
    CCAmount   : currency;
    CCRefCnt   : integer;
    CCRefund   : currency;
    TECount    : integer;    // AMEX/Diners Club/Carte Blanche
    TEAmount   : currency;
    DSCount    : integer;    // Discover
    DSAmount   : currency;
    DSRefCnt   : integer;
    DSRefund   : currency;
    VMCount    : integer;    // Visa/MasterCard
    VMAmount   : currency;
    VMRefCnt   : integer;
    VMRefund   : currency;
    AOCount    : integer;    // Pre-Auth Only
    AOAmount   : currency;
    DBCount    : integer;    // Debit
    DBAmount   : currency;
    DBRefCnt   : integer;
    DBRefund   : currency;
    FLCount    : integer;    // Fleet
    FLAmount   : currency;
    CSCount    : integer;    // Cash
    CSAmount   : currency;
    PRCount    : integer;    // Proprietary / private label
    PRAmount   : currency;
    PRRefCnt   : integer;
    PRRefund   : currency;
    CKCount    : integer;    // Check
    CKAmount   : currency;
    EFCount    : integer;    // EBT Food Stamps
    EFAmount   : currency;
    EFRefCnt   : integer;
    EFRefund   : currency;
    ECCount    : integer;    // EBT Cash Benefit
    ECAmount   : currency;
    ECRefCnt   : integer;
    ECRefund   : currency;
    CBCount    : integer;    // Cash back
    CBAmount   : currency;
    SV1Count   : integer;    // Store Value Activation/Deactivation
    SV1Amount  : currency;
    SV2Count   : integer;    // Store Value Purchase/Completion
    SV2Amount  : currency;
    SV3Count   : integer;    // Store Value Replacement
    SV3Amount  : currency;
    SV4Count   : integer;    // Store Value Recharge
    SV4Amount  : currency;
    //53d...
    OLCount    : integer;    // Offline/stand-in (locally maintained - not returned by host)
    OLAmount   : currency;
    //...53d
  end;
//...bp



  // Data stucture used to hold product information that requires scanning (of barcode)
  // and swipping (of MSR track data).
  pActivationProductType = ^TActivationProductType;
  TActivationProductType = record
    bNextScanForProduct : boolean;
    bThisScanForProduct : boolean;
    bNextSwipeForProduct : boolean;
    bThisSwipeForProduct : boolean;
    ActivationUPC : string;
    ActivationMSR : string;
    ActivationPhoneNo : string;
    ActivationCardType : string;
    ActivationCardNo : string;
    ActivationCardName : string;
    ActivationExpDate : string;
    ActivationEntryType : string;
    ActivationAmount : currency;
    ActivationRestrictionCode : integer;
  end;


  //XMD
  pPromoData = ^TPromoData;
  TPromoData = record
    PromoID : Integer;
    PromoCount : Double;
    PromoDesc : string[20];
    PromoDisc : Currency;
    PromoSKUArray : array[0..100,0..1] of string[14]; //0..100 of SKU 0..1 of count
  end;
  //XMD


  TMsgData = record
    Orig: string;
    TerminalNo : Integer;
    Msg: string;
  end;
  pMsgData = ^TMsgData;

  pFSData = ^TMsgData;
  TFSData = TMsgData;

  pCCData = ^TMsgData;
  TCCData = TMsgData;

  //20050222
  pOutFSData = ^TOutFSData;
  TOutFSData = record
    Orig : string;
    TerminalNo : byte;
    OutMsg : string;
  end;
  //20050222

  //20050228
  pScannedPLU = ^TScannedPLU;
  TScannedPLU = record
    PLU : Double;
    KeyType: string[3];
  end;

  pScannedKSL = ^TScannedKSL;
  TScannedKSL = record
    KSL : string;
  end;

  KBRec = record         // Keyboard Data - used for POS Kybd
    KeyType: string[3];
    KeyVal:  string[5];
    Preset:  string[10];
  end;

  TCompleteLogonRec = record
    bAlreadyLoggedOn        : boolean;
    bSupportAlreadyLoggedOn : boolean;
    OnTerminal              : Integer;
  end;
  pCompleteLogonRec = ^TCompleteLogonRec;

  TKybdRec = record   //Keyboard Data - used for Touch Interface
    AltNo         : short;
    MenuNo        : short;
    AutoMenuClose : boolean;
    KeyCode       : string[3];
    KeyType       : string[30];
    KeyVal        : string[12];
    Preset        : string[10];
    BtnColor      : string[20];
    BtnColorNo    : integer;
    BtnShape      : short;
    BtnFont       : string[30];
    BtnFontColor  : string[30];
    BtnFontColorNo : TColor;
    BtnFontSize   : short;
    BtnFontBold   : short;
    BtnLabel      : string[30];
    KeyCaption    : string[30];
    BtnVisible    : boolean;
    MgrLock       : boolean;
  end;

  TKybdArray = array[0..90] of TKybdRec;

  TResumeKeyMode = (mResumeKeyInit, mResumeKeyTerminalNotClosed, mResumeKeyTerminalClosed);
//...cwa

 type
  TIntegerArray = array of array of Int64;
  TfmPOS = class(TForm)
    StatusBar1: TStatusBar;
    Timer1: TTimer;
    DisplayEntry: TEdit;
    lSuspend: TLabel;
    DisplayQty: TEdit;
    lReceipt1: TLabel;
    lReceipt2: TLabel;
    lbReturn: TLabel;
    Track2Timer: TTimer;
    FuelPriceTimer: TTimer;
    KeyPanel: TBevel;
    lTotal: TLabel;
    eTotal: TEdit;
    POSListBox: TPOSListBox;
    PopUpMsgTimer: TTimer;
    PumpPanel: TPanel;
    PopupMenu1: TPopupMenu;
    Exit1: TMenuItem;
    OPOSScanner: TOPOSScanner;
    IBConfigService1: TIBConfigService;
    IBBackupService1: TIBBackupService;
    IBRestoreService1: TIBRestoreService;
    LoggingOn1: TMenuItem;
    ReceiptEvents: TReceiptSrvrITReceiptEvents;
    CarwashEvents: TCarwashICarwashOLEEvents;
    FPCPostTimer: TTimer;
    PPLogging: TMenuItem;
    menuShowCursor: TMenuItem;
    PumpPopupMenu: TPopupMenu;
    UnlockPump: TMenuItem;
    PowerPump: TMenuItem;
    DepowerPump: TMenuItem;
    menuFuelMsgLogging: TMenuItem;
    TMGauge1: TGauge;
    TMGauge2: TGauge;
    TMGauge3: TGauge;
    TMGauge4: TGauge;
    TMGauge5: TGauge;
    SysMgrPopup: TPopupMenu;
    SyncLogging1: TMenuItem;
    Button1: TButton;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure POSError(ErrMsg: string; supplement:string='');
    //20050217
    procedure FSSocket1ReceiveMessage(var XMsg : TMessage); Message WM_FSMSG;
    procedure CCSocketReceiveMessage(var XMsg : TMessage); Message WM_CCMSG;
    procedure MOSocketReceiveMessage(var XMsg : TMessage); Message WM_MOMSG;

    procedure CCSendMsg(const msg : string; const respdest : TMsgRecEvent);
    //procedure FSSocket1ReceiveMessage( Orig: string; TerminalNo : Integer; Msg: string);
    //procedure CCSocketReceiveMessage( Orig: string; TerminalNo : Integer;  Msg: string);
    //20050217

    //20050228
    procedure SendScannedPLU(var Msg: TMessage); Message WM_SCANNED_PLU;
    procedure SendScannedKSL(var Msg: TMessage); Message WM_SCANNED_KSL;
    //20050228
    procedure ProcessActivation(var Msg: TWMStatus); message WM_ACTIVATION;
    function SalesItemQualifiesForAuthReduction(const qSalesData : pSalesData) : boolean;
    procedure BalanceOverTender();
    procedure ActivationResponded(var Msg: TWMStatus); message WM_ACTIVATION_RESPONDED;
    //cwa...
    procedure CWSocketReceiveMessage( Orig: string; TerminalNo : Integer;  Msg: string);
    //...cwa
    procedure Track2TimerTimer(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FuelPriceTimerTimer(Sender: TObject);
    procedure PriceSignPortTriggerAvail(CP: TObject; Count: Word);
    procedure MSRPortDataEvent(const Value : String);
    procedure PopUpMsgTimerTimer(Sender: TObject);
    //procedure ScannerPortTriggerAvail(CP: TObject; Count: Word);
    procedure ScannerPortDataEvent(const Sym: String; const BarCode: String);
    procedure OPOSScannerDataEvent(Sender: TObject; Status: Integer);
    function  LicenseDateParse(instr : String) : TDateTime;
    function  LicenseValidate(instr : String; sym : String) : Boolean;
    procedure SysMgr1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure LoggingOn1Click(Sender: TObject);
    procedure UpdateLoggingDisplay();
    procedure PPLoggingClick(Sender: TObject);
    procedure UpdatePPLoggingDisplay();
    procedure OPOSMSRErrorEvent(Sender: TObject; ResultCode,
      ResultCodeExtended, ErrorLocus: Integer;
      var pErrorResponse: Integer);
    procedure OPOSScannerErrorEvent(Sender: TObject; ResultCode,
      ResultCodeExtended, ErrorLocus: Integer;
      var pErrorResponse: Integer);
    procedure ProcessPriceCheck();
    procedure ReceiptEventsGotPrinterError(Sender: TObject;
      const Error: WideString);
//    procedure CarWashEventsGotMsgEvent(Sender: TObject;
//      const Dest: WideString; TerminalNo: Integer; const Msg: WideString);
    procedure CreditEventsGotPOSMsg(Sender: TObject;
      TerminalNo: Integer; const Msg: WideString);
    //DSG
    procedure AddGiftFuelDisc;
    procedure VoidGiftFuelDisc;
    procedure DisplayEntryKeyPress(Sender: TObject; var Key: Char);
    procedure CarwashEventsGotMsg(Sender: TObject; const Dest: WideString;
      TerminalNo: Integer; const MSG: WideString);
    procedure FPCPostTimerTimer(Sender: TObject);
    procedure InjectionPortTriggerAvail(CP: TObject; Count: Word);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ChangeCCKeyColor(const ColorIdx : byte);
    procedure UpdateCCKeyColor();
    procedure menuShowCursorClick(Sender: TObject);
    procedure PumpMenuItemClick(Sender: TObject);
    procedure QueryValidCard(const seqno : integer;
                             const Track1: ansistring = ''; const Track2: ansistring = '';
                             const acctno: ansistring = ''; const expdate: ansistring = '';
                             const track : ansistring = '';
                             const encryptedtrackdata : ansistring = ''; const EMVTags : ansistring='');
    procedure UpdateIndicatorLocations(sb : TStatusBar);
    procedure menuFuelMsgLoggingClick(Sender: TObject);
    procedure UpdateFuelLoggingDisplay();
    procedure SyncLogging1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);


    //DSG
  private
    { Private declarations }
    //TIntegerArray : array of array of Integer;
    FPolePort: TApdComPort;
    KybdPort: TApdComPort;
    FPriceSignPort: TApdComPort;
    MSRPort: TMSR;
    CoinPort: TApdComPort;
    InjectionPort: TApdComPort;
    FSaleState : TSaleState;
    //Gift
    CSTaxList : TRTLCriticalSection;  //20041215
    FPinCreditSelect : integer;
    //Gift
    FFPCPostThread : TFPCPostThread;
    ScannerPorts : array of TScanner;
    scannercomports : array of integer;

    ScalePort : TApdComPort;
    scale : TScale;

    FCurSaleList : TNotList;
    FCurSalesTaxList   : TNotList;
    FPostSalesTaxList  : TList;
    FSavSalesTaxList   : TList;
    FPostSaleList      : TNotList;
    FRestrictedDeptList: TList;
    FPopUpMsgList      : TList;
    FOutFSList         : TThreadList;
    FCCCardTypesList    : TStringList;

    FInjBlock : Array[0..8191] of char;
    FInjLen : integer;
    FPinPadOnlineEvent : TEvent;

    PumpLockMgr : TPumpLockMgr;

    FCardActivationTimeout : TDateTime;

    FTMList : TList;

    FuelHost   : string;
    CreditHost : string;
    CreditDefs : TStringList;
    MCPHost   : string;
    MOHost    : string;
    cipherlist : string;
    bFuelMsgLogging    : Boolean;
    lastLineID : integer;
    arprdcode : TIntegerArray;

    function InjFrameAvailable: boolean;
    function InjGetFrame: string;
    procedure InjHandle(const cmd: string);
    procedure InjLog(const msg : string);

    procedure OnPinPadSwipeChange(Sender : TObject);

    procedure DailyBackup(var Msg: TMessage); message WM_BACKUP;
    procedure FirstLogOn(var Msg: TMessage); message WM_FIRSTLOGON;
    procedure CheckKey(var Msg: TWMPOSKey); message WM_CHECKKEY;
    procedure PreProcessKey(var Msg: TMessage); message WM_PREPROCESSKEY;
    procedure KillPOS(var Msg: TMessage); message WM_KILLPOS;
    procedure ShowPumpInfo(var Msg: TMessage); message WM_SHOWPUMPINFO;
    procedure CompleteLogon(var Msg: TMessage); message WM_COMPLETELOGON;

    procedure UpdatePinPad(var Msg : TMessage); message WM_UPDATEPINPAD;
    procedure MSRSwipeVCI(const pVCI : pValidCardInfo);
    procedure ActivationVCI(const pVCI : pValidCardInfo);

    procedure ProcessKey(const sKeyType : string; const sKeyVal : string; const sPreset : string; const bMgrLock : boolean);
    //Kiosk
    procedure ProcesskeyKSL;
    //Kiosk
    //PDO
    procedure ProcessKeyPDO;
    //PDO
    procedure ProcessKeyCLK;
    procedure ProcessKeyCKN;
    procedure ProcessKeyPRT;
    procedure ProcessKeyNUM(const sKeyVal : string);
    procedure ProcessKeyPRS;
    procedure ProcessKeyPSL;
    procedure ProcessKeyPPY;
    procedure ProcessKeyPPR;
    procedure ProcessKeyCOP;
    procedure ProcessKeyPDA;
    procedure ProcessKeyMNU(const sKeyVal : string);
    procedure ProcessKeyDPT(const sKeyVal : string; const sPreset : string);
    procedure ProcessKeyPLU(const sKeyVal : string; const sPreset : string);
    procedure ProcessKeyMOD(const sPreset : string);
    procedure ProcessKeyUP;
    procedure ProcessKeyDN;
    procedure ProcessKeyMED(const sKeyType : string ; const sKeyVal : string ; const sPreset : string ;
                            const bPostTender : boolean);
    procedure FinalizeSale();
    procedure ProcessKeyCWH();
    procedure ProcessKeyCWR;
    function RequestCarwashAccessCode(var CarwashPLUNo : int64; var sCWExpDate : string) : string;
    procedure ProcessKeyGFT;
    procedure ProcessKeyNSL;
    procedure ProcessKeyCNL;
    procedure ProcessKeyQTY;
    procedure ProcessKeyDSC(const sKeyVal : string);
    {$IFDEF FUEL_PRICE_ROLLBACK}
    procedure ProcessKeyAFD;
    procedure AdjustFuelPriceOnSalesList(const FuelMediaNo : integer);
    function PaymentQualifiesForDiscountedFuelPrice(const FuelMediaNo : integer;
                                                    const FuelCardType : string) : boolean;
    {$ENDIF}
    procedure ProcessKeySP1;
    procedure ProcessKeyCFP;
    procedure ProcessKeyRPD;
    procedure ProcessKeyRPE;
    procedure ProcessKeyRPF;
    procedure ProcessKeyEOD(const ResumeMode : TResumeKeyMode);
    procedure ReleasePumps();
    procedure ProcessKeyEOS(const ResumeMode : TResumeKeyMode);
    procedure ProcessReport(const sKeyType : string);
    procedure ProcessKeyREC;
    procedure ProcessKeyCCR;
    procedure ProcessKeyPFR;
    procedure ProcessKeySR;
    //Mega Suspend
    procedure ProcessKeySR2;
    procedure ProcessKeyPBL;
    //Mega Suspend
    procedure ProcessKeyBNK(const sKeyVal : string);
    procedure ProcessKeyCRL;
    procedure ProcessKeyUSO;
    procedure ProcessKeyTAX;
    procedure ProcessKeyBAR(const ResumeMode : TResumeKeyMode);
    procedure ProcessKeyASU(const ResumeMode : TResumeKeyMode);
    procedure ProcessKeySCR;
    //Build 18
    procedure ProcessKeyPOR;
    //Build 18

    //Inventory
    procedure ProcessKeyINV;
    //Inventory
    procedure ProcessKeyMOI();
    procedure ProcessKeyMOP();
    procedure ProcessKeyMOL();
    procedure ProcessKeyMOA();
    procedure ProcessKeyMOR();

    function PostItemSale : pSalesData;
    //procedure PostItemVoid;
    {$IFDEF PDI_PROMOS}
    procedure CheckForPDIAdjustment;
    {$ELSE}
    procedure CheckForAdjustment(const CurSaleData : pSalesData);
    //20070606a...
//    procedure AutoDisc(DiscType : string; DiscNo : integer; DiscAmount : currency);
//    function  MMSplitAdjust : currency;
    function AutoDisc(const item: pSalesData; const DiscType : string; const DiscNo : integer; const UnitDiscAmount : currency; const DiscountQty : integer; taxno : integer=0) : pSalesData;
    function LastSaleItem( sl : TNotList ) : integer;
    function  MMSplitAdjust(const CurSaleData : pSalesData; var cUnitDiscountAmount : currency; var iUnitDiscountQuantity : integer; const bReset : boolean = False) : currency;
    //...20070606a
    function  MMComboAdjust(const CurSaleData : pSalesData; MMTypeName, MMNoNameA : integer;MMNoName : double) : currency;
    procedure RecomputeDiscount(const CurSaleData : pSalesData);
    {$ENDIF}

    procedure BeginToFinalize;
    function AddSaleList() : pSalesData;
    procedure DisplaySaleList(const CurSaleData : pSalesData; const bDisplayAtCurrentPosition : boolean = False);
    {$IFDEF MULTI_TAX}
    procedure AddTaxList;
    {$ENDIF}
    function AddMediaList(const Med : pDBMediaRec) : pSalesData;
    procedure moveCRDintoSaleData(pCRD: pCreditResponseData; CurSaleData : pSalesData);
    procedure DisplayMedia(const qSalesData : pSalesData; const qOriginalSalesData : pSalesData = nil);
    procedure ComputeSaleTotal;
    procedure DisplaySaleTotal;

    

    procedure InitScreen;
    procedure InitTaxList;
    procedure InitPopUpMsgList;
    procedure InitPopUpMsgRecord;

    procedure InitTaxRecord(cst : pSalesTax);
    procedure LoadPLUMemTable;
//cwe    procedure LoadKeyBoard;
    procedure BuildPOSTouchScreen;
    function  NameTheKey(KybdNdx, BtnNdx  : integer) : string;
    procedure BuildPOSButton(RowNo, ColNo, BtnNdx : short );
    procedure DisplayTouchKeys(KybdNdx, BtnNdx : short );
    function SetPOSButtonFontColor(KybdNdx, BtnNdx : short ): TColor;
    procedure CreateKybdQuery(KybdNdx, MenuNo : short );
    procedure CreateModifierKybdQuery(KybdNdx, MenuNo : short );
    procedure DisplayModifierMenu(ModifierGroup : currency );
    procedure DisplayMenu(MenuNo : short );
    procedure SuspendSale;
    procedure RecallSale;
    function RestrictionCodeOK(RestrictionCode : integer): Boolean;
    function DepartmentMaxCountOK(DeptNo, MaxCount : integer) : boolean;
    function CustAgeOK(AgeRestriction : integer): Boolean;
    function SalesComplete: Boolean;
    procedure ClosePorts;
    procedure LoadSetup;
    procedure SetupDevice(DeviceType : integer);
    procedure SetupPorts;
    procedure AssignPorts(nDeviceType, nDeviceNo, nDriver, nPort, nBaud, nData, nStop : integer;
              nParity : TParity; OPOSName : string );
    procedure CreatePumpIcons(Sender : TObject);
    function  GetScreenPosition (Item, Itemcount, Width : Integer ) : Integer;
    procedure DisplayReceipts(const sKeyType : string);
    Procedure DisplayReceiptlines;
    procedure PrintDailyReport (DayId, Terminal, Shift : Integer);
    procedure FuelTotalsReport(Reprint : boolean);
    procedure PLUReport (DayId, Terminal, Shift : Integer );
    procedure PLUReportToDisk (DayId, Terminal, Shift : Integer );
    procedure MOReport(ReportToDisk : boolean);
    procedure CashDropReport (DayId, Terminal, Shift : Integer );
    procedure HourlyReport(DayId, Terminal, Shift : Integer );
    procedure PLUList;
    procedure CheckCCBatch;
    function EnforceWindow(Value : TWinControl) : boolean;
    function EnforceWindows() : boolean;
//cwe    procedure LogIt( sMsg: shortstring; iMs: Integer);
    procedure FuelButtonClick(Sender: TObject);
    procedure FuelButtonDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure FuelButtonDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure FuelButtonMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FuelButtonLongPress(Sender: TObject);

    function GetPinCreditSelect() : integer;
    procedure SetSaleState(Value : TSaleState);
    function SaleStateStr(Value : TSaleState) : string;

    //Gift
    {$IFDEF FF_PROMO_20080128}
    function VerifyFuelFirstCard(const CardNumberUsed : string) : boolean;
    {$ENDIF}
    procedure GiftCardBalanceInquiry();
    procedure BuildRestrictedDeptList();
    procedure BuildCardTypeList();
    function GetCardTypeNameByCardType(const cardtype : string) : string;
    //Gift
//bp...
    procedure ProcessCardTotals();
    function VoidPriorCredit(const VoidTransNo       : integer;
                             const VoidAmount        : currency;
                             const VoidCardNo        : string;
                             const bDebitTransaction : boolean   ) : boolean;
//bph...
    procedure ReDisplayVoidedCreditSale();
//...bph
//...bp
    //gift-20040708...
    function EncodeGiftCardInfoInDeptName(const sd : pSalesData) : string;
    //...gift-20040708

    function CheckNCRMSR(MSROPOSName : string) : Boolean;

    //20071018a...
    procedure UpdateKioskPrices;  //20071107f
    //...20071018a
    procedure PPVCIReceived(const pVCI : pValidCardInfo);
    procedure PPCardInfoReceived(sender : TObject; const Track1, Track2, CardNo, Track, EncryptedTrackData, EMVTags : widestring);  // called by pin pad to validate card
    procedure PPAuthInfoReceived(      Sender        : TObject;
                                 const PinPadAmount  : currency;
                                 const PinPadMSRData : string;
                                 const PINBlock      : string;
                                 const PINSerialNo   : string);    // called by pin pad to authorize card
    procedure PPSigReceived(     Sender   : TObject;
                            const AuthId : integer;
                            const SigData : string);
    function PPPromptChange(      Sender         : TObject;
                            const PinPadStatusID : string;
                            const PinPadPrompt   : string) : boolean;
    procedure PPOnlineChange(     Sender         : TObject);
    procedure PPCustomerDataReceived(Sender : TObject; const exittype : TPPEntryExitType; const entrytype : TPPEntry; const entry : string);
    procedure PPSerialNoChanged(const msg : string);
    procedure PPPhoneNumberReceived(Sender : TObject; const exittype : TPPEntryExitType; const entry : string);
    procedure DisplaySaleDataToPinPad(PP : TPinPadTrans ; SD : pSalesData);
    procedure SendCancelOnDemand(PP : TPinPadTrans);
    procedure SendCardRead(PP : TPinPadTrans);
    property PopUpMsgList : TList read FPopUpMsgList;
    property outFSList : TThreadList read FoutFSList;
    procedure AbortPinPadOperation();
    //procedure OnIBEjectRequest(Sender : TObject);
    procedure StartFPCThread();
    procedure InitActivationDataForSaleItem(const qActivationProductType : pActivationProductType);
    procedure CheckItemForActivation(const qSalesData : pSalesData;
                                     const qActivationProductType : pActivationProductType);
    procedure SetPolePort(const poleport : TApdComPort);
    function GetPolePort : TApdComPort;
    procedure DisposeSalesListItems(l : TNotList);
    Function ParseTdCode(parseCode: String) : TIntegerarray;
    procedure ProcessTdBarCode(TdCode : String );
  public

    //DCOMFuelProg        : ITFuelProg;

    //DCOMBuypassCredit   : ITBuypassCrdtSrvr;
    //cwa...
    Zipper: TAbZipper;    
    DCOMCarWash         : ICarwashOLE;//ICarWash;
    //...cwa
    //DCOMNBSCredit       : ITNBSCrdtSrvr;
    //DCOMADSCredit       : ITADSCrdtSrvr;
    DCOMPrinter         :  ITReceipt;

    FuelTCPClient : TIdTCPClient;
    Fuel : TTagTCPClient;

    CreditTCPClient : TIdTCPClient;
    Credit : TTagTCPClient;

    MCPTCPClient : TIdTCPClient;
    MCP : TTagTCPClient;

    PPTrans : TPINPadTrans;
    PPStatus : TPPStatus;

    MOTCPClient : TIdTCPClient;
    MO : TTagTCPClient;

    MCPStatus, CreditStatus, FuelStatus, MOStatus : TIndicator;

    bPlayWave           : Boolean;

    nSelectedPumpNo : short;
    nSelectedSaleID : integer;
    ConsolidateShifts : boolean;

    ThisTerminalNo          : short;
    ThisTerminalUNCName     : string;
    ThisTerminalAppDrive    : string;

    MasterTerminalNo        : short;
    MasterTerminalUNCName   : string;
    MasterTerminalAppDrive  : string;

    BackUpTerminalNo        : short;
    BackUpTerminalUNCName   : string;
    BackUpTerminalAppDrive  : string;

    POSTerminalHardware : short;    //1 = PC, 2 = NCR 7453, 3 = NCR 7454
    POSScreenSize   : short;    //1 = 1024, 2 = 800, 3 = Auto
    ReportToDisk    : boolean;
    bDebitAllowed   : Boolean;
    //53o...
    bEBTFSAllowed       :  boolean;
    bEBTCBAllowed       :  boolean;
    bCreditSelectNeeded : boolean;
    //...53o
    //build 13
    bSyncF1EOD      : boolean;

    //Gift
    bGiftAllowed    : boolean;
    bGiftPurchase   : boolean;//added to handle pin pad messaging
    //20020205...
//    bGiftFailed     : boolean;
    //...20020205
    //Gift
    //53l...
    VehicleNo : widestring;
    ZipCode : widestring;
    //...53l
    DriverID : string;
    RefNo : string;
    Odometer : string;
    nCustBDayLog : TDateTime;
//bp...
    bCardTotalsReceived : boolean;
    CardTotalsDateCode : string;
//...bp
    PrintPaused : boolean;
    //DSG
    bGiftRestrictions : boolean;
    //DSG

    CSSuspendList : TRTLCriticalSection;
    OnlineT99Switch : Boolean;
    OnlinePINVerified : Boolean;
    EMV_Received_33_03 : Boolean;
    Config : TConfigRW;
    function NullIntToStr(aInt : Integer) : String;
    procedure CreateJsonFromReceiptList();
    procedure POSButtonClick(Sender: TObject);
    //20070307a...
    procedure POSListBoxClick(Sender: TObject);
    procedure POSListBoxMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);  //20070425a
    procedure eTotalClick(Sender: TObject);
    //...20070307a
    procedure ProcessKeyERC;
    procedure ErrorCorrect;
    function GetLineID() : integer;
    procedure BackupAndRestore;
    function  ShutdownApp(const name : string; const winname : string; const exename : string = '') : boolean;
    procedure ApplySoftwareUpdate;
    function  SoftwareUpdatePending : boolean;
    function  DependentSoftwareUpdatePending : boolean;
    function  LocalSoftwareUpdatePending : boolean;
    function FilesInFolder(const Path : string) : boolean;
    procedure UpdatePinPadFiles();
    procedure CopyUpdateFile(UpdateFileName : string);
    procedure OpenTables(Verbose : boolean);
    procedure CloseTables;
    procedure AssignTransNo;
    procedure ClearEntryField;
    procedure ConnectCreditServer;
    procedure CreditConnected(Sender : TObject);
    procedure CreditDisconnected(Sender : TObject);
    procedure CreditLog(Sender : TObject; logmsg : string);
    procedure CreditMsgRecv(Sender : TObject; msg : string);
    procedure ReComputeSaleTotal(bRestrictedOnly : boolean);
    procedure RedisplaySalesItemsToPinPad();
    procedure PrintEMVDeclinedReceipt(VERIFIED_PIN : Boolean);
    function FormatFinalizeAuth(const AuthID      : integer;
                                const FinalAmount : currency;
                                const TransNo     : integer;
                                const salelist    : TNotList) : string;
    procedure SendCreditMessage(CreditMsg : string);
    procedure ReConnectCredit(CalledFrom, EMess, CreditMsg : string; TryCount : integer);
    procedure ConnectCarWashServer;
    procedure SendCarWashMessage(CarWashMsg : string);
    procedure ReConnectCarWash(CalledFrom, EMess, CarWashMsg : string; TryCount : integer);
    function GetCarwashAccessCode(qSalesData : pSalesData) : string;
    function GetCarwashExpDate(qSalesData : pSalesData) : string;
    //XMD
    function GetXMDEarned(qSalesData : pSalesData) : string; deprecated;
    //XMD
    procedure ConnectFuelServer;
    procedure FuelConnected(Sender : TObject);
    procedure FuelDisconnected(Sender : TObject);
    procedure FuelLog(Sender : TObject; logmsg : string);
    procedure FuelMsgRecv(Sender : TObject; msg : string);
    procedure ReConnectFuel(CalledFrom, EMess, FuelMsg : string; TryCount : integer);
    procedure SendRawFuelMessage(FuelMsg : string);
    

    procedure ConnectMCP;
    procedure MCPConnected(Sender : TObject);
    procedure MCPDisconnected(Sender : TObject);
    procedure MCPLog(Sender : TObject; logmsg : string);
    procedure MCPMsgRecv(Sender : TObject; msg : string);
    procedure SendMCPMessage(Msg : string);

    procedure ConnectMOServer(reconnect : boolean);
    procedure SendMOSMessage(Msg : string);
    procedure MOConnected(Sender : TObject);
    procedure MODisconnected(Sender : TObject);
    procedure MOLog(Sender : TObject; logmsg : string);
    procedure MOMsgRecv(Sender : TObject; msg : string);

    procedure ReConnectPrinter(CalledFrom, EMess : string; TryCount : integer);
    procedure ReConnectPinPad(CalledFrom : string);
    procedure SendFuelMessage(PumpNo, Action : short; Amount : currency; SaleID, TransNo, DestPump : integer);
    procedure SendFuelMessageBusy(var Msg : TMessage); message WM_OUTFSMSG;
    function  CreateTMGauge(tankno : integer) : TGauge;
    procedure UpdateTMDisplay(const msg : string);
    procedure FuelMessage(var Msg: TWMFuel); message WM_FUELMSG;
    procedure DisplayReceiptErrorMessage(var Msg: TWMReceiptErrorMsg); message WM_RECEIPTERRORMSG;
    procedure ProcessCOP(var Msg: TWMCOP); message WM_COPMSG;
    procedure ProcessFuel(var Msg: TWMProcessFuel); message WM_PROCESSFUEL;
    procedure ProcessPrePay(var Msg: TWMProcessPrePay); message WM_PROCESSPREPAY;
    procedure ProcessPrePayRefund(var Msg: TWMProcessPrePayRefund); message WM_PROCESSPREPAYREFUND;
    procedure PostPrePay(var Msg: TWMPostPrePay); message WM_POSTPREPAY;
    {$IFDEF ODOT_VMT}
    procedure AddVMTDEPSale( VMTFee : currency; VMTReceiptData : WideString );
    procedure AddVMTDisc(const DiscountAmount : currency; const GradeNo : integer);
    {$ENDIF}
    procedure ProcessKeyPMP(const sKeyVal : string; const sKeyPreset : string);
    procedure ProcessKeyPST;
    procedure ProcessKeyPAT;
    procedure ProcessKeyPAL;
    procedure ProcessKeyPHL;
    procedure ProcessKeyEHL;
    procedure ProcessKeyCAT;
    procedure ProcessKeyCT1;
    procedure ProcessKeyCT2;
    procedure ProcessKeyCT3;
    procedure ProcessKeyFUL;
    procedure ProcessKeyPRF;
    procedure ProcessKeyCDT;
    procedure ProcessKeyPLR;  //print last receipt
    procedure ProcessKeyPFL;  //print fuel only receipt
    procedure SelectFuelSale(var Msg: TMessage); message WM_SELECTFUELSALE;
    procedure CreditReport(DayId, ShiftNo : Integer);
    procedure CreditSetup;
    procedure EmptyReceiptList;
    function  OverDrawerLimit: boolean;
    procedure SetNextDollarKeyCaption;
    //Gift
    function PumpPrePayTotal() : currency;
    function GiftCardTotal() : currency;
    
    property PolePort : TApdComPort read getpoleport write setpoleport;
    property PriceSignPort :TApdComPort read FPriceSignPort write FPriceSignPort;

    property PinCreditSelect : integer read GetPinCreditSelect write FPinCreditSelect;
    //Gift
    property  SaleState : TSaleState read FSaleState write SetSaleState;

    function PartialTender : boolean;
    function CreditHostReal(const CreditAuthType : integer) : boolean;
    function CreditHostAllowsTotals(const CreditAuthType : integer) : Boolean;
    procedure DisconnectScanner;
    procedure ConnectScanner;
    procedure XMDItemVoid(const CurSaleData : pSalesData); deprecated;
    procedure ProcessKioskPLU(const sKeyVal : string ; const sPreset : string);
    //dma...
    function DebitBINQualify(const PurchaseAmount : currency; const BINCardType : string) : boolean;
    //...dma
    //Mega Suspend
    procedure DisplaySuspend(const CurSaleData : pSalesData);
    //20040827...
    function AdjustFoodStampChargeAmount(const AttemptAmount : currency; const AttemptCardType : string) : currency;
    //...20040827
    {$IFDEF DEV_PIN_PAD}
    function ValidateCardInfo(const qValidCardInfo : pValidCardInfo) : boolean;
    {$ENDIF}
    {$IFDEF CISP_CODE}
    function MaskCardNumber(const UnMaskedCardNo : string) : string;
    function UseCISPEncryption(const HostID : integer) : boolean;
    {$ENDIF}
    {$IFDEF UPC_EXPAND}
    //20060922a...
    function ValidateUPCCheckDigit(enteredUPC : string; computedUPC : string) : string;  //Support for Kiosk and UPC conversions
    //...20060922a
    {$ENDIF}
    //20070104a...
    function UseCashbackAmountPrompt() : boolean;
    function UseCashbackOptionPrompt() : boolean;
    function UseCashbackPrompt() : boolean;
    //...20070104a
    function BuildKioskConnectionString : string;  //20070501a
    procedure AddSalesListBeforeMedia(const AddSalesData : pSalesData);
    {$IFDEF FUEL_PRICE_ROLLBACK}
    function AdjustFuelPriceForTender(const AmountToTender : currency;
                                      const FuelMediaNo : integer;
                                      const FuelCardType : string) : boolean;
    {$ENDIF}
    procedure PostItemVoid(const CurSaleData : pSalesData);
    procedure CheckSaleList;
    //20110608h...
    function IsActivationQueued() : boolean;
    //...20110608h
    procedure QueryLoggedOnInfo(const SeqNo : integer; UserID : integer);
    procedure SendUserID(const Msg : string);
    procedure ReduceAuth(const transno : integer; const qSalesData : pSalesData; const FinalAuthAmount : currency);
    property CurSaleList : TNotList read FCurSaleList;
    property CurSalesTaxList : TNotList read FCurSalesTaxList;
    property PostSalesTaxList : TList read FPostSalesTaxList;
    property SavSalesTaxList : TList read FSavSalesTaxList;
    property PostSaleList : TNotList read FPostSaleList;
    property RestrictedDeptList : TList read FRestrictedDeptList;
    procedure SendSetTransactionType(PP : TPinPadTrans);
    procedure SendSetAmount(PP : TPinPadTrans);    
  end;

var

  fmPOS: TfmPOS;


  //Gift
  SaveEntryBuff : array [0..200] of char;
//bpz...
{$IFDEF CAT_SIMULATION}
  bCATSimulation : boolean;             // CATSim
  CATSimulationTrack1 : string;         // CATSim
  CATSimulationTrack2 : string;         // CATSim
  CATSimulationFuelMsg : string;        // CATSim
{$ENDIF}
//...bpz
  GIFT_CARD_RESTRICTION_DESC : array [0..NUM_GIFT_CARD_RESTRICTION_CODES] of string;

  TmpSalesTax    : pSalesTax;
  GiftCardDeptNo       : integer;
  GiftCardFaceValueMin : currency;
  GiftCardFaceValueMax : currency;
  GiftCardFaceValueInc : currency;
  bClearDisplayAfterError : boolean;
  ccAuthID : integer;
  //Gift

  SavSalesTax    : pSalesTax;
  CurSalesTax    : pSalesTax;
  PostSalesTax   : pSalesTax;

  PostSaleData   : pSalesData;

  {$IFDEF ODOT_VMT}  //20061023f
  ReceiptDataNextLine : pSalesData;
  {$ENDIF}

  PopUpMsg       : pPopUpMsg;

  KybdArray      : array[0..40] of TKybdArray;
  KybdArrayNdx   : short;

  //XMD
  XMDPromoList   : TList;
  //XMD
  //20050217
  FSList         : TThreadList;
  CCList         : TThreadList;
  MOList         : TThreadList;
  //20050217

  qClient                : pCreditClient;

  CarwashClient : array [0..NUM_CARWASH_CLIENTS - 1] of TCarwashClient;
  qCWClient              : pCarwashClient;
  sCarwashAccessCode : string;
  sCarwashExpDate : string;

  SuspendList       : TList;

  SuspendCreditList : TList;


  POSDate     : TDateTime;

  StatusMsg                  : pStatusMsg;
  COPMsg                     : pCOPMsg;
  ProcessFuelMsg             : pProcessFuelMsg;
  ProcessPrePayMsg           : pProcessPrePayMsg;
  ProcessPrePayRefundMsg     : pProcessPrePayRefundMsg;
  PostPrePayMsg              : pPostPrePayMsg;

  sPLUKeyCode: string; // Used with UPC Codes

  nNextDollarKey : integer;
  nCCKey : integer;

  nModifierValue : integer;
  nModifierName : string;

  KeyBuff: array[0..200] of Char;
  EntryBuff: array[0..200] of Char;
  BuffPtr: short;
  symbology: string;

  nAgeValidationType    : integer;
  bCaptureNFPLU         : Boolean;
  bNeedModifier         : Boolean;
  bSuspendedSale        : Boolean;
  bSaleComplete         : Boolean;
  bCCUsed               : Boolean;
  bDebitUsed            : Boolean;
  bOpenDrawer           : Boolean;
  bUseDefaultModifier   : Boolean;
  bSyncShiftChange      : Boolean;
  bUseFoodStamps        : Boolean;
  nFuelInterfaceType    : integer;
  nCATInterfaceType     : integer;

  nUseStartingTill      : Integer;
  nStartingTillDefault  : Currency;

  nCashBackType         : integer;
  nMaxCashBack          : Currency;
  nCashAmount1          : currency;
  nCashAmount2          : currency;
  nCashAmount3          : currency;

  bEODRptDaily          : Boolean;
  bEODRptHourly         : Boolean;
  bEODRptFuelTls        : Boolean;
  bEODRptCashDrop       : Boolean;
  bEODRptPLU            : Boolean;

  bEOSRptDaily          : Boolean;
  bEOSRptHourly         : Boolean;
  bEOSRptFuelTls        : Boolean;
  bEOSRptCashDrop       : Boolean;
  bEOSRptPLU            : Boolean;

  bEOSRptCredit         : Boolean;
  bEOSBatchBalance      : Boolean;

  nTillTimer            : integer;
  dTillOpenTime         : TDateTime;
  nDaysHistory          : integer;
  nDaysBackup           : integer;
  bBackUpDone           : boolean;
  nCreditSuspendTime    : TDateTime;

  //Build 26
  bMSRActive            : short;
  bPINPadActive         : short;
  bReceiptActive        : short;
  bScannerActive        : short;
  bCashDrawerActive     : short;
  bCoinDispenserActive  : short;
  bCutReceipt           : boolean;
  bAutoFont             : boolean;
  bScanStarted          : boolean;

  bKeyboardActive   : short;
  bPriceSignActive  : short;

  bPOSForceClose     : boolean;
  bPostingSale       : boolean;
  bPostingCATSale    : boolean;
  bPostingPrePaySale : boolean;

  bScrollMessOn       : Boolean;
  bScrollMessActive   : Boolean;
  bClearListBox       : Boolean = True;
  bCompulseDwr        : Boolean;
  nDwrLimit           : Currency;
  bFuelSystem         : Boolean;
  bLeftHanded         : Boolean;
  bScreenBuilt        : boolean;
  bTouchScreen        : Boolean;

  bAllowMgrLock       : Boolean;
  bMgrLock            : Boolean;

  bEODPopUpMsg        : Boolean;
  bEOSPopUpMsg        : Boolean;
  bUserPopUpMsg       : Boolean;
  bPopUpMsg           : Boolean;
  bPrintVoids         : Boolean;

  nPumpAuthMode       : short;
  nCreditAuthType     : short;

  SearchOption        : TLocateOptions;

  sEntry              : string;
  sPumpNo             : string;
  bSkipOneKey         : Boolean;
  nTimercount         : Integer;

  nCaptureNFPLUNumber : Double;
  nNumber             : Double;
  nAmount             : Currency;
  nExtAmount          : Currency;
  nQty                : Currency;
  nPumpNo             : short;
  nDiscNo             : short;
  nDiscType           : string;
  nDiscAmount         : currency;
  nLinkedPLUNo        : Double;

  nPumpVolume         : currency;
  nPumpAmount         : currency;
  nPumpUnitPrice      : currency;
  nPumpSaleID         : integer;

  sLineType           : string[3];
  sSaleType           : string[4];
  sDiscName           : string;

  rCRD                : TCreditResponseData;

  sCreditMediaNo      : string;
  sCreditMediaName    : string;

  sDebitMediaNo       : string;
  sDebitMediaName     : string;

  //Gift
  sGiftCardMediaNo    : string;
  sGiftCardMediaName  : string;
  //Gift

  //53o...
  sEBTFSMediaNo       : string;
  sEBTFSMediaName     : string;

  sEBTCBMediaNo       : string;
  sEBTCBMediaName     : string;
  //...53o

//20071019a  {$IFDEF FUEL_FIRST}
  sDriveOffMediaNo    : string;
  sDriveOffMediaName  : string;

  iCATAuthID          : integer = 0;
  iCATCardType        : integer = 0;
//20071019a  {$ENDIF}


  //bp...
  sTerminalID         : string;
  //53o...
  //...53o
  HostTotals          : THostTotals;
  //...bp


  nTotalCheckCount    : integer;

  nCustBDay, nBeforeDate : TDateTime;

  curSale : TSaleHeader;
  pstSale : TSaleHeader;
  rcptSale : TSaleHeader;

  nSeqLink             : short;
  genSeqLink           : boolean;

  ChangeCents          : short;
  ChangeOutBuff        : array[0..10] of byte;

  nSavFSSubtotal       : Currency;
  nSavSubtotal         : Currency;
  nSavTlTax            : Currency;
  nSavTotal            : Currency;
  //Gift
  nSavMedia            : Currency;
  //Gift
  nSavCustBDay,
  nSavBeforeDate       : TDateTime;
  nSavNonTaxable       : Currency;
  nSavDiscable         : Currency;


  nRcptShiftNo          : integer;

  nShiftNo      : Integer;

  nOldTransNo   : Integer;

  nScrollPtr    : short;
  nScrollSize   : short;
  sScrollBuff   : shortstring;
  sScrollMess   : string;

//  {$IFDEF FUEL_FIRST}
//  PumpCATInfo    : array[1..MaxPumps] of TPumpCATInfo;
//  {$ENDIF}
  nPumpIcons    : TPumpArray;
  POSButtons    : array[1..88] of TPOSTouchButton;


  TopKeyPos     : short ;
  MaxKeyNo      : short ;
  MaxKeyRow     : short ;

  nCurMenu      : short;


  SelPumpIcon      : TPumpxIcon;

  KeyCount, MessageCount : short;


  CName      : string;

  fFuelTotals    : boolean;
  nFuelTotalID   : integer;

  fCreditTotals   : boolean;
  fPushedEOD      : boolean;
  //cwj...
  fCarwashTotals : boolean;
  //...cwj
  nCreditBatchID  : integer;
  nCreditBatchPDL : integer;

  ErrorDisplayMsg : String;
  ErrorStatusArr  : Array[1..MaxPumps] of Byte;     { Flag if Printerproblem at Pump }

  PriceSgnItemNo        : Short;
  PriceSgnChg           : Boolean;
  PriceIncrease         : Boolean;
  MaxPriceItems         : Short = 2; {Zero based ie 2=(3 Total items}
  MaxPriceWait          : Short = 18; {Actual time depends on trigging time on timer}
  MaxTime               : Longint = 90000; {Trigger time between price files checks}
  PriceChgTime          : Longint = 5000; {Trigger time between Price chgs once a price files has been recieved}

  // Keyboard Table in Memory
  KBDef: array['A'..'N', '1'..'8'] of KBRec;

  POSRegEntry   : TRegIniFile;

  sOPOSPtrName   : string;

  sReportLogName : string;
  sDataLogName : string;

  PtrDeviceNo   : integer;
  PtrDriver     : integer;
  PtrPort       : integer;
  PtrBaud       : integer;
  PtrData       : integer;
  PtrStop       : integer;
  PtrParity     : integer;
  PtrOPOSName   : string;

  DwrDeviceType : integer;
  DwrDriver     : integer;
  DwrPort       : integer;
  DwrBaud       : integer;
  DwrData       : integer;
  DwrStop       : integer;
  DwrParity     : integer;
  DwrOPOSName   : string;

  MSROPOSName   : string;

  //From Dept Table
  Dept : TDBDeptRec;
  //From PLU Table
  PLU : TDBPLURec;

  //From Media Table
  Media : TDBMediaRec;

  //From Bank
  BankBANKNO	: integer;
  BankNAME      : string[20];
  BankHALO	: currency;
  BankRECTYPE	: integer;

  //From PLUMod
  PLUModPLUNO   : double;
  PLUModPLUMODIFIER	: integer;
  PLUModPLUPRICE	: currency;
  PLUModPLUMODIFIERGROUP: double;
  {$IFDEF PLU_MOD_DEPT}
  PLUModDEPTNO	: integer;  //GMM: Added for Departments at PLU Modifier level
  PLUModSplitQty	: integer;  //GMM: Added for Split Quantity at PLU Modifier level  //20060717a
  PLUModSplitPrice	: currency;  //GMM: Added for Split Price at PLU Modifier level  //20060717a
  {$ENDIF}

  //From Modifier
  ModMODIFIERGROUP	: double;
  ModMODIFIERNO	        : integer;
  ModMODIFIERNAME	: string[10];
  ModMODIFIERVALUE	: integer;
  ModMODIFIERDEFAULT    : integer;

  //From Disc
  DisDISCNO	        : integer;
  DisNAME	        : string[20];
  DisREDUCETAX	        : integer;
  DisAMOUNT	        : currency;
  DisRECTYPE	        : string[1];

  Mix : TDBMixMatchRec;

  Setup : TSetupRec;
  {$IFDEF DAX_SUPPORT}
  bDAXDBConfigured : boolean;     //20071128a
  {$ENDIF}
  bTempLogon : boolean;
  //...53g
  //Build 25
  PAN : boolean;
  //Build 25
  fmPOSIcon: TTrayIcon;
  SysMgrIcon : TTrayIcon;

  //XMD
  XMDHostUNC      : string;
  XMDMaxVolume,
  XMDDaysToExpire : Byte;
  nXMDCode        : Double;
  bXMDEarned      : Boolean;
  bXMDActive      : boolean;
  //XMD

  //SecExp
  bSecurityActive : Boolean;
  bSecurityLogging : Boolean;
  //SecExp

  //Kiosk
  bKioskActive : Boolean;
  KioskOrderNo : Integer;
  KioskPLU : Double;
  KioskPLUPrice :Currency;
  KioskPLUDesc : string[30];
  //Kiosk

  {$IFDEF DEV_PIN_PAD}
  LastValidCardInfo : TValidCardInfo;
  {$ENDIF}

  DriveOffNoise,
  RespondNoise,
  ValidateAgeNoise,
  EnterDateNoise,
  CATHelpNoise : Byte;

  bPrintingPriorReceipt : boolean;  //20070529a

  {$IFDEF FF_PROMO}
  FuelFirstCardNoUsed : string;
  {$ENDIF}

  ActivationProductData : TActivationProductType;

  //20060719...
  // Department numbers for fuel
  DEPT_NO_UNLEADED : integer;
  DEPT_NO_PLUS     : integer;
  DEPT_NO_SUPER    : integer;
  DEPT_NO_DIESEL   : integer;
  DEPT_NO_KEROSENE : integer;
  //...20060719

  OPOSMSR : TOPOSMSR;

  MOInfo : TMORec;


implementation

uses POSDM, POSLog, POSPost, GetAge, POSErr, POSPrt, POSPole, NBSCC, Receipt,
  CWAccess, FuelSel, Reports, plurpt, POSMsg, CCRecpt, FuelPric, PumpOnOf, FuelRcpt,
  PosUser, PriceSgn, PLUSearch, TermNo, ViewRpt, OldRecpt, PopMsg,
  StartingTill, SelTermShift, PumpInfo, ExceptLog, FactorImport, EnterAge,
  PriceCheck, PriceOverride, Clock, PDIImport, SysMgrImport,
//  {$IFDEF DEV_TEST}
//  SnowBirdEx,
//  {$ENDIF}
  Encrypt,
  EncryptKey1, EncryptKey2,
  {$IFDEF CASH_FUEL_DISC}
  GiftFuelDiscount,
  {$ENDIF}
  {$IFDEF UPC_EXPAND}
  StrUtils,
  {$ENDIF}
  CardActivation,
  Sounds, Kiosk, KioskForm, SelectSuspend, Inventory, MOStat,
  MOLoad, DateUtils, Mainmenu, NTProcess, SigVerify, IngSig,
  EClasses,
  PumpLockSup,
  AdManage,
  GiftForm,
  IdSSLOpenSSLHeaders,
  PPEntryPrompt,
  LatConst,
  MedRestrict,
  PTVerify, MODocNo, ScaleWeight;

{$R *.DFM}
//SecExp
var
  //Kiosk
  KioskFrame : TKioskFrame;
//SecExp
  ReceiptList  : TList;
  ReceiptData    : pSalesData;

  CreditClient : array [0..NUM_CREDIT_CLIENTS - 1] of TCreditClient;
  qSuspendedCreditClient : pCreditClient;
  qSuspendedClient       : pCreditClient;

{-----------------------------------------------------------------------------
  Name:      TfmPos.PumpPrePayTotal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    currency
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPos.PumpPrePayTotal() : currency;
// Add up total amount of all pump pre-pays to be purchased.
var
  GCSum : currency;
  j : integer;
  sd : pSalesData;
begin
  GCSum := 0.0;
  for j := 0 to CurSaleList.Count - 1 do
    begin
      sd := CurSaleList.Items[j];
      if ((sd^.LineType = 'PPY') and (not sd^.LineVoided) and (sd^.SaleType = 'Sale')) then
          GCSum := GCSum + sd^.ExtPrice;
    end;
  PumpPrePayTotal := GCSum;
end;  // function PumpPrePayTotal

{-----------------------------------------------------------------------------
  Name:      TfmPos.GiftCardTotal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    currency
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPos.GiftCardTotal() : currency;
// Add up total amount of all gift cards to be purchased.
var
  GCSum : currency;
  j : integer;
  sd : pSalesData;
begin
  GCSum := 0.0;
  for j := 0 to CurSaleList.Count - 1 do
    begin
      sd := CurSaleList.Items[j];
      if ((sd^.DeptNo = GiftCardDeptNo) and (not sd^.LineVoided) and (sd^.SaleType = 'Sale')) then
          GCSum := GCSum + sd^.ExtPrice;
    end;
  GiftCardTotal := GCSum;
end;  // function GiftCardTotal
//Gift

function TfmPOS.GetPinCreditSelect() : integer;
begin
  if (PPTrans <> nil) and (PPTrans.PinPadOnLine) and (PPTrans.Enabled) then
  begin
    if (PPTrans.PinPaymentSelect <> PIN_NO_TYPE) then
      FPinCreditSelect := PPTrans.PinPaymentSelect;
  end;
  GetPinCreditSelect := FPinCreditSelect;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.SetSaleState
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Value : TSaleState
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.SetSaleState(Value : TSaleState);
begin
  //20041020
  if (FSaleState = ssNoSale) and (Value = ssSale) then
  begin
    KeyBuff := '';
    EntryBuff := '';
    LoadPLUTax;
    FCardActivationTimeOut := 0;
  end
  else if ((FSaleState = ssSale) or (FSaleState = ssTender)) and (Value = ssNoSale) then
  begin
    fmNBSCCform.ClearCardInfo();
    FCardActivationTimeOut := 0;
    try
      if assigned(fmPOS.PPTrans) then
        with fmPOS.PPTrans do
        begin
          PinPadAmount := 0.0;
          PinPadFSAmount := 0.0;
          PinPadFuelAmount := 0.0;
        end;
    except
    end;
  end;

  //20041020
  if bPinPadActive = 3 then
  begin
    if (FSaleState = ssNoSale) and (Value = ssSale) then
    begin
      {$IFDEF DEV_PIN_PAD}
      CreditPromptFlags := PINPAD_PROMPT_NONE;
      {$ENDIF}
      PinCreditSelect := 0;
      DriverID := '';
      Odometer := '';
      RefNo := '';
      ZipCode := '';
      //53l...
      bPOSGetVehicleNo := False;
      //...53l
      bPOSGetDriverID := False;
      bPOSGetOdometer := False;
      bPOSGetRefNo := False;
      //53l...
      bPOSGotVehicleNo := False;
      bPOSGotZipCode   := False;
      //...53l
      bPOSGotDriverID := False;
      bPOSGotOdometer := False;
      bPOSGotRefNo := False;
      PostMessage(fmPOS.Handle,WM_UPDATEPINPAD,0,0);
      (*try
        //dmb...
        //DCOMPinPad.GetPaymentMethod(bGiftPurchase);
        DCOMPinPad.GetSwipe();
        //...dmb
      except
        on E : Exception do
        begin
          UpdateExceptLog('Reconnecting to Pin Pad ' + e.message);
          ReconnectPinPad;
        end
        else
        begin
          UpdateExceptLog('Reconnecting to Pin Pad');
          ReconnectPinPad;
        end;
      end;*)
    end
    else if (FSaleState <> ssNoSale) and (Value = ssNoSale) then
    begin
      {$IFDEF DEV_PIN_PAD}
      CreditPromptFlags := PINPAD_PROMPT_NONE;
      {$ENDIF}
      try
        //DCOMPinPad.ResetData;
      except
        UpdateExceptLog('Reconnecting to Pin Pad');
        ReconnectPinPad('SetSaleState');
      end;
      {$IFDEF DEV_PIN_PAD}
      bExpectCashBackAmount := False;
      {$ENDIF}
      DriverID := '';
      Odometer := '';
      RefNo := '';
      //53l...
      bPOSGetVehicleNo := False;
      //...53l
      bPOSGetDriverID := False;
      bPOSGetOdometer := False;
      bPOSGetRefNo := False;
      //53l...
      bPOSGotVehicleNo := False;
      bPOSGotZipCode   := False;
      //...53l
      bPOSGotDriverID := False;
      bPOSGotOdometer := False;
      bPOSGotRefNo := False;
    end;
  end;

  if FSaleState <> Value then
  UpdateZLog(Format('SaleState changing from %s to %s', [SaleStateStr(FSaleState), SaleStateStr(Value)]));
  FSaleState := Value;
end;

function TfmPOS.SaleStateStr(Value : TSaleState) : string;
begin
//  TSaleState = (ssNoSale, ssSale, ssTender, ssBankFunc, ssBankFuncTender );

  if Value = ssNoSale then Result := 'No Sale'
  else if Value = ssSale then Result := 'Sale'
  else if Value = ssTender then Result := 'Tender'
  else if Value = ssBankFunc then Result := 'Bank Func'
  else if Value = ssBankFuncTender then Result := 'Bank Func Tender'
  else Result := 'Unknown';
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.BackUpAndRestore
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.BackUpAndRestore;
var
BackupFileName, CWMsg, CCMsg : string;
x, i, c, RepeatCount : integer;
DBRenamed, ServiceStopped : boolean;
begin
  CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_PAUSE_SERVER));
  SendCarWashMessage(CWMsg);
  //...cwa

  POSDataMod.PostEvent('Eject');

  if bSyncF1EOD then
  begin
    fmPOSMsg.ShowMsg('Waiting for F1 EOD', '');
    for c := 1 to 5000 do
    begin
      Application.ProcessMessages;
      sleep(1);
    end;
  end;

  {$IFDEF ESF_NET}//20070515a
  if not EODInProgress then
  {$ENDIF}
  begin
    CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_PAUSECREDIT));
    SendCreditMessage(CCMsg);
    CCMsg := BuildTag(TAG_MOCMD, IntToStr(CMD_MODBDISABLE));
    SendMOSMessage(CCMsg);
  end;


  for c := 1 to 1000 do
    Application.ProcessMessages;

  for c := 1 to 50 do
    begin
      Application.ProcessMessages;
      sleep(1);
    end;

  for c := 1 to 1000 do
    Application.ProcessMessages;

  fmPOSMsg.ShowMsg('Housekeeping', '');
  CleanUpDir (MasterTerminalAppDrive + ':\Latitude\Data', '\*.gdbsav*', 7);

  fmPOSMsg.ShowMsg('Closing Database', '');
  CloseTables;

  fmPOSMsg.ShowMsg('Starting BackUp Service', '');

  BackUpFileName := MasterTerminalAppDrive + ':\Latitude\Data\RsgData.Bak';

  DeleteFile(BackUpFileName);

  IBBackupService1.ServerName   := MasterTerminalUNCName;
  IBBackupService1.Protocol     := Local;
  IBBackupService1.LoginPrompt  := False;
  IBBackupService1.DataBaseName := MasterTerminalAppDrive + ':\Latitude\Data\RsgData.gdb';

  IBBackupService1.BackupFile.Clear;
  IBBackupService1.BackupFile.Add( BackUpFileName );

  IBBackupService1.Params.Clear;
  IBBackUpService1.Params.Add('user_name=rsgretail');
  IBBackUpService1.Params.Add('password=pos');

  IBBackupService1.Active := True;
  IBBackupService1.Verbose := False;
  IBBackupService1.ServiceStart;
  fmPOSMsg.ShowMsg('Backing Up Database', '');
  while not IBBackupService1.Eof do
    fmPOSMsg.ShowMsg('', IBBackUpService1.GetNextLine, 0);
  IBBackupService1.Active := False;

  IBConfigService1.ServerName   := MasterTerminalUNCName;
  IBConfigService1.Protocol     := Local;
  IBConfigService1.LoginPrompt  := False;
  IBConfigService1.DataBaseName := MasterTerminalAppDrive + ':\Latitude\Data\RsgData.gdb';
  IBConfigService1.Params.Clear;
  IBConfigService1.Params.Add('user_name=rsgretail');
  IBConfigService1.Params.Add('password=pos');
  IBConfigService1.Active := True;
  try
    IBConfigService1.ShutdownDatabase(Forced, 0);
    for x := 1 to 1000 do
      begin
        if IBConfigService1.IsServiceRunning then
          sleep(3)
        else
          break;
      end;
  finally
    IBConfigService1.Active := False;
  end;

  ServiceStopped := False;
  DBRenamed := False;
  for i := 1 to 10 do
    begin
      //20071018b.. Show updated message
      fmPOSMsg.ShowMsg('Renaming Database', '');
      Application.ProcessMessages;
      //...20071018b
      if RenameFile(MasterTerminalAppDrive + ':\latitude\data\rsgdata.gdb', MasterTerminalAppDrive + ':\latitude\data\rsgdata.gdbsav' + FormatDateTime('yymmdd', Now) + Format('%2.2d',[ i ]) ) then
        begin
          fmPOSMsg.ShowMsg('', 'Original Database Renamed');
          DBRenamed := True;
          break;
        end;
      //20071018b...
//      if i = 1 then  // if it fails the first time, stop the service
//        begin
        if FileExists(MasterTerminalAppDrive + ':\latitude\data\rsgdata.gdbsav' + FormatDateTime('yymmdd', Now) + Format('%2.2d',[ i ])) = false then
        begin
          // Log that database open during rename attempt
          UpdateExceptLog('Database open during rename attempt - Interbase service stopped');
      //...20071018b
          fmPOSMsg.ShowMsg('', 'Stopping Interbase Service');
          ServiceStopped := True;
          try
            WinExecAndWait32('net stop "Interbase Server"' , SW_SHOWMINIMIZED);
          except
             fmPOSMsg.ShowMsg('', 'Stop Service Failed');
          end;
          //20071018b...
          if RenameFile(MasterTerminalAppDrive + ':\latitude\data\rsgdata.gdb', MasterTerminalAppDrive + ':\latitude\data\rsgdata.gdbsav' + FormatDateTime('yymmdd', Now) + Format('%2.2d',[ i ]) ) then
          begin
            fmPOSMsg.ShowMsg('', 'Original Database Renamed');
            DBRenamed := True;
            break;
          end;
          //...20071018b
        end;

    end;

  if ServiceStopped then
    begin
      fmPOSMsg.ShowMsg('', 'Starting Interbase Service');
      try
        WinExecAndWait32('net start "Interbase Guardian"' , SW_SHOWMINIMIZED);
      except
        fmPOSMsg.ShowMsg('', 'Start Service Failed');
      end;
      try
        WinExecAndWait32('net start "Interbase Server"' , SW_SHOWMINIMIZED);
      except
        fmPOSMsg.ShowMsg('', 'Start Service Failed');
      end;
      sleep(1000);
    end;

  if DBRenamed then
    begin
      RepeatCount := 1;
      while true do
        begin

          try
            fmPOSMsg.ShowMsg('Restoring Database', '');

            IBRestoreService1.ServerName   := MasterTerminalUNCName;
            IBRestoreService1.Protocol     := Local;
            IBRestoreService1.LoginPrompt  := False;
            IBRestoreService1.DataBaseName.Clear;
            IBRestoreService1.DataBaseName.Add( MasterTerminalAppDrive + ':\Latitude\Data\RsgData.gdb');
            IBRestoreService1.BackupFile.Clear;
            IBRestoreService1.BackupFile.Add( BackUpFileName );
            IBRestoreService1.Params.Clear;
            IBRestoreService1.Params.Add('user_name=rsgretail');
            IBRestoreService1.Params.Add('password=pos');
            IBRestoreService1.Verbose := False;
            IBRestoreService1.Active := True;
            IBRestoreService1.ServiceStart;
            while not IBRestoreService1.Eof do
              fmPOSMsg.ShowMsg('', IBRestoreService1.GetNextLine, 0);
            IBRestoreService1.Active := False;

            fmPOSMsg.ShowMsg('Activating New Database', '');
            break;
          except
            try
              WinExecAndWait32('net start "Interbase Guardian"' , SW_SHOWMINIMIZED);
            except
            end;
            sleep(1000);
            try
              WinExecAndWait32('net start "Interbase Server"' , SW_SHOWMINIMIZED);
            except
            end;
            sleep(1000);
            inc(repeatCount);
            DeleteFile(MasterTerminalAppDrive + ':\latitude\data\rsgdata.gdb');
            if repeatcount > 5 then
              begin
                RenameFile(MasterTerminalAppDrive + ':\latitude\data\rsgdata.gdbsav' + FormatDateTime('yymmdd', Now) + Format('%2.2d',[ i ]), MasterTerminalAppDrive + ':\latitude\data\rsgdata.gdb');
                DBRenamed := False;
                break;
              end;
          end;
        end;
    end;

  if NOT DBRenamed then
    begin
      POSError('Unable to Rename Database. Restore Incomplete.');
      UpdateExceptLog('Unable to Rename Database. Restore Incomplete.');
    end;

  IBConfigService1.ServerName   := MasterTerminalUNCName;
  IBConfigService1.Protocol     := Local;
  IBConfigService1.LoginPrompt  := False;
  IBConfigService1.DataBaseName := MasterTerminalAppDrive + ':\Latitude\Data\RsgData.gdb';
  IBConfigService1.Params.Clear;
  IBConfigService1.Params.Add('user_name=rsgretail');
  IBConfigService1.Params.Add('password=pos');
  IBConfigService1.Active := True;
  try
    IBConfigService1.BringDataBaseOnline;
  finally
    IBConfigService1.Active := False;
  end;
  OpenTables(True);
  Setup.LASTBACKUP := Now();                                                     //20070709a
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Update Setup Set LastBackup = :pLastBackup');
      ParamByName('pLastBackup').AsDateTime := Setup.LASTBACKUP;                 //20070709a (param value had been Now())
      ExecSQL;
    end;
  if POSdataMod.IBTransaction.InTransaction then
    POSdataMod.IBTransaction.Commit;

  {$IFDEF ESF_NET}//20070515a
  if not EODInProgress then
  {$ENDIF}
  begin
    CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_RESUMECREDIT));
    SendCreditMessage(CCMsg);
    CCMsg := BuildTag(TAG_MOCMD, IntToStr(CMD_MODBENABLE));
    SendMOSMessage(CCMsg);
  end;

  //20070227a...
  if bPinPadActive <> 0 then
  begin
    fmPosMsg.ShowMsg('','Restarting Pinpad server');
    fmPOS.ReConnectPinPad('Backup/Restore');
    fmPosMsg.Close;
  end;
  //...20070227a

  //cwa...
  CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_RESUME_SERVER));
  SendCarWashMessage(CWMsg);
  fmPOSMsg.Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DailyBackup
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.DailyBackup(var Msg: TMessage);
var
zAppName:array[0..512] of char;
zCurDir:array[0..255] of char;
WorkDir:String;
StartupInfo:TStartupInfo;
ProcessInfo:TProcessInformation;
begin

  StrPCopy(zAppName, '\Latitude\DBBackup.exe');
  GetDir(0,WorkDir);
  StrPCopy(zCurDir,WorkDir);
  FillChar(StartupInfo,Sizeof(StartupInfo),#0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := SW_HIDE;
  if not CreateProcess(nil,
                       zAppName, { pointer to command line string}
                       nil, { pointer to process security attributes }
                       nil, { pointer to thread security attributes }
                       false, { handle inheritance flag }
                       CREATE_NEW_CONSOLE or { creation flags } NORMAL_PRIORITY_CLASS,
                       nil, { pointer to new environment block }
                       nil, { pointer to current directory name }
                       StartupInfo, { pointer to STARTUPINFO }
                       ProcessInfo) then  { pointer to PROCESS_INF }
  else
    begin
     CloseHandle( ProcessInfo.hProcess );
     CloseHandle( ProcessInfo.hThread );
    end;

  UpdateExceptLog('Daily Backup Complete');

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPRT
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPRT;
begin
  ReconnectPrinter('Printer Reset', 'No Error', 1);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyBAR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyBAR(const ResumeMode : TResumeKeyMode);
var
  c : integer;
  CCMsg : string;
  CWMsg : string;
  iFuelActiveCount : integer;
  j : integer;
begin
  if (ResumeMode = mResumeKeyInit) then
  begin
    if (ThisTerminalNo = MasterTerminalNo) then
      QueryLoggedOnInfo(LU_RET_BAR, 0)
    else
      POSError('This Function Must Be Run From The Master Terminal');
    exit;
  end
  else if (ResumeMode = mResumeKeyTerminalNotClosed) then
  begin
    POSError('Please Log-Off Other Terminals Before Running BackUp-Restore');
    exit;
  end;

  // If no exit above, then this procedure was called after verfying that no other users logged in.

  //20070409c...
  iFuelActiveCount := 0;
//  if not POSDataMod.IBTempTrans1.InTransaction then
//    POSDataMod.IBTempTrans1.StartTransaction;
//  with POSDataMod.IBTempQry1 do
//  begin
//    close;SQL.Clear;
//    SQL.Add('Select count(*) as FuelActiveCount from FuelTran where completed = 0');
//    open;
//    if (not EOF) then
//      iFuelActiveCount := FieldByName('FuelActiveCount').AsInteger;
//    close;
//  end;
//  if POSDataMod.IBTempTrans1.InTransaction then
//    POSDataMod.IBTempTrans1.Commit;
    for j:= 1 to No_Pumps do
    begin
      if (not (nPumpIcons[j].Frame in [FR_IDLENOCAT, FR_STOP, FR_COMMDOWN, FR_IDLECATOFF, FR_IDLECATON])) then
      begin
        Inc(iFuelActiveCount);
        break;
      end;
    end;
  if (iFuelActiveCount > 0) then
  begin
    POSError('Fuel Transactions Must Complete Before Running BackUp-Restore');
    exit;
  end;
  //...20070409c

  //20070409b...
  if (fmPOSErrorMsg.YesNo('POS Confirm', 'System will be out of service for several minutes.  Continue') = mrOk) then
  begin
  //...20070409b

    PopUpMsgTimer.Enabled := False;
    fmPOS.Timer1.Enabled := False;  //20071018b

    fmPOSMsg.ShowMsg('Beginning Backup/Restore', '');

    //cwa...
    CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_PAUSE_SERVER));
    SendCarWashMessage(CWMsg);
    //...cwa

    {$IFDEF ESF_NET}//20070515a
    if not EODInProgress then
    {$ENDIF}
    begin
      CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_PAUSECREDIT));
      SendCreditMessage(CCMsg);
    end;
    
    CCMsg := BuildTag(TAG_MOCMD, IntToStr(CMD_MODBDISABLE));
    SendMOSMessage(CCMsg);

    SendFuelMessage(0, PMP_PAUSEALL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );

    for c := 1 to 1000 do
      Application.ProcessMessages;

    for c := 1 to 50 do
      begin
        Application.ProcessMessages;
        sleep(1);
      end;

    for c := 1 to 1000 do
      Application.ProcessMessages;

    fmPOS.Refresh;
    fmPOSMsg.ShowMsg('Beginning Backup Restore', '');

    BackUpAndRestore;

    {$IFDEF ESF_NET}//20070515a
    if not EODInProgress then
    {$ENDIF}
    begin
      CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_RESUMECREDIT));
      SendCreditMessage(CCMsg);
    end;

    CCMsg := BuildTag(TAG_MOCMD, IntToStr(CMD_MODBENABLE));
    SendMOSMessage(CCMsg);

    //cwa...
    CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_RESUME_SERVER));
    SendCarWashMessage(CWMsg);
    //...cwa

    SendFuelMessage(0, PMP_RESUMEALL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );

    //20061018d... Reset PinPad after Backup/Restore
    if bPinPadActive <> 0 then
    begin
      fmPosMsg.ShowMsg('','Restarting Pinpad server');
      fmPOS.ReConnectPinPad('Backup/Restore');
      fmPosMsg.Close;
    end;
    //...20061018d

    ProcesskeyUSO;
    PopUpMsgTimer.Enabled := True;
  end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.SoftwareUpdatePending
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    boolean
  Purpose:
-----------------------------------------------------------------------------}
function TfmPOS.SoftwareUpdatePending : boolean;
{
Checks to see if any files have been loaded into the "update" folders.
}
begin
  Result := DependentSoftwareUpdatePending or
            LocalSoftwareUpdatePending;
end;

function TfmPOS.DependentSoftwareUpdatePending : boolean;
begin
  Result := FilesInFolder('\Latitude\Update\CreditServer.exe') or
            FilesInFolder('\Latitude\Update\FuelProg.exe') or
            FilesInFolder('\Latitude\Update\CATSrvr.exe') or
            FilesInFolder('\Latitude\Update\MOServer.exe');
end;

function TfmPOS.LocalSoftwareUpdatePending : boolean;
begin
  Result := FilesInFolder('\Latitude\Update\Latitude.exe') or
            FilesInFolder('\Latitude\Update\LatitudeUpdate.exe') or
            FilesInFolder('\Latitude\Update\ReceiptSrvr.exe') or
            FilesInFolder('\Latitude\Update\Sysmgr.exe') or
            FilesInFolder('\Latitude\Update\LatitudeMnu.txt') or
            FilesInFolder('\Latitude\Update\LatitudeKyb.txt') or
            FilesInFolder('\Latitude\Update\LatitudeKyb.txt') or 
            FilesInFolder('\Latitude\Update\Ingenico\*.*');
end;

function TfmPOS.FilesInFolder(const Path : string) : boolean;
{
Determines if a non-directory file exists in a folder.
}
var
  FileAttrs : integer;
  sr : TSearchRec;
  RetValue : boolean;
begin
  FileAttrs := faAnyFile and (not faDirectory);
  RetValue := (FindFirst(path, FileAttrs, sr) = 0);
  FindClose(sr);
  FilesInFolder := RetValue;
end;

procedure TfmPOS.UpdatePinPadFiles();
{
Download any files that have been staged in the download directory to the PIN pad device.
}
begin
  // If pin pad configured:
  if (PPTrans <> nil) and (PPTrans.PinPadOnLine) then
    PPTrans.UpdatePinPadFiles();
end;  // procedure UpdatePinPadFiles


function TfmPOS.ShutdownApp(const name : string; const winname : string; const exename : string = '') : boolean;
var
  i, j, DelayTime : integer;
  ServerAppHandle  : Hwnd;
  ProcessList : TNTProcessList;
  Process : TNTProcess;
  en : string;
  handle : Thandle;
  found : boolean;
begin
  i := 1;
  Repeat
    fmPOSMsg.ShowMsg('', 'Stopping ' + name + ' ' + IntToStr(i) );
    ServerAppHandle := FindWindow(PChar(winname), nil);
    If (ServerAppHandle <> 0) Then
    Begin
      if not DestroyWindow(ServerAppHandle) then
      begin
        For DelayTime:= 1 to 100 do
          Application.ProcessMessages;
        Inc(i);
        sleep(SU_LOOP_WAIT);
      end;
    end
    else
      break;
  Until i > 2;
  if (FindWindow(PChar(winname), nil) <> 0) and (exename <> '') then
  begin
    j := 0;
    UpdateExceptLog('fmPOS.ShutdownApp: Resorting to hard methods for ' + exename);
    ProcessList := TNTProcessList.Create(Self);
    Process := TNTProcess.Create(Self);
    repeat
      found := false;
      if ProcessList.Count > 0 then
      begin
        for i := 0 to ProcessList.Count - 1 do
        begin
          ProcessList.GetProcess(i,Process);
          try
            en := Process.BaseName;
          except
            en := 'UNKNOWN';
          end;
          if exename = en then
          begin
            UpdateExceptLog('fmPOS.ShutdownApp: Found ' + exename + ' at pid ' + IntToStr(ProcessList.PID[i]));
            found := true;
            handle := OpenProcess (PROCESS_TERMINATE, False, ProcessList.PID[i]);
            if handle <> 0 then
            try
              Windows.TerminateProcess(handle, 0);
            except
              on E: Exception do
                UpdateExceptLog('fmPOS.ShutdownApp: Cannot TerminateProcess - ' + E.Message);
            end;
          end;
        end;
      end;
      sleep(200);
      ProcessList.Refresh;
      inc(j);
    until (not found) or (j > 5);
    Process.Free;
    ProcessList.Free;
  end;
  Result := (FindWindow(PChar(winname), nil) = 0);
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ApplySoftwareUpdate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ApplySoftwareUpdate;

var
  FileNameList : TStringList;
  FileAttrs : integer;
  sr : TSearchRec;
  path, ext : string;
  ucname : string;
  ndx : short;
  DBUpdateName     : string;
  bDBUpdate        : boolean;
  bCatSrvr    : boolean;

  SleepTime : cardinal;
  DelayTime : cardinal;

  //bADSCredit       : boolean;
  bCredit          : boolean;
  //bBuypassCredit   : boolean;
  //cwa...
  bCarWash         : boolean;
  //...cwa
  bFuelProg        : boolean;
  bFuelSim         : boolean;
  bFuelAllied      : boolean;
  bReceiptSrvr     : boolean;
  bPinPadSrvr      : boolean;  //20070116a
  bSysMgr          : boolean;
  bLatitude        : boolean;
  bPOSUpdate       : boolean;
  bMenuUpdate      : boolean;
  bButtonUpdate    : boolean;
  bMsgUpdate       : boolean;
  bSecurity        : Boolean;
  bMOServer        : Boolean;
  bFuelStop, bCATstop : boolean;
  zAppName:array[0..512] of char;
  zCurDir:array[0..255] of char;
  WorkDir:String;
  StartupInfo:TStartupInfo;
  ProcessInfo:TProcessInformation;
  i,j              : Integer;
  ServerAppHandle  : Hwnd;
  InFile : TextFile;
  InStrng : string;
  SaveFileNameListCount : integer;


begin
  i := 0;
  // First get a list of files in the update directory
  if not POSDataMod.IBTempTrans1.InTransaction then
    POSDataMod.IBTempTrans1.StartTransaction;
  with POSDataMod.IBTempQry1 do
  begin
    close;SQL.Clear;
    SQL.Add('Select * from setup');
    open;
    SleepTime := 100 * (fieldbyname('UpdateTimer').AsInteger+1);
    close;
  end;
  if POSDataMod.IBTempTrans1.InTransaction then
    POSDataMod.IBTempTrans1.Commit;
  fmPOSMsg.ShowMsg('Applying Software Update', '');

  //Build 21
  FileNameList := TStringList.Create;
  FileAttrs := 0;
  path := '\Latitude\SWBackup\*.*';
  FileAttrs := FileAttrs + faAnyFile;
  if FindFirst(path, FileAttrs, sr) = 0 then
  begin
    if (sr.Attr and FileAttrs) = sr.Attr then
    begin
      if NOT ((sr.name = '.') or (sr.name = '..')) then
        FileNameList.Add(sr.name);
    end;
    while FindNext(sr) = 0 do
    begin
      if (sr.Attr and FileAttrs) = sr.Attr then
      begin
        if NOT ((sr.name = '.') or (sr.name = '..')) then
          FileNameList.Add(sr.name);
      end;
    end;
    FindClose(sr);
  end;
  for ndx := 0 to FileNameList.Count - 1 do
  begin
    DeleteFile('\Latitude\SWBackup\'+FileNameList.Strings[ndx]);   // save the name as it will
    FileNameList.Strings[ndx] := '';
  end;
  FileNameList.Free;
  //Build 21

  FileNameList := TStringList.Create;
  FileAttrs := 0;
  path := '\Latitude\Update\*.*';
  FileAttrs := FileAttrs + faAnyFile;
  if FindFirst(path, FileAttrs, sr) = 0 then
  begin
    repeat
      if (sr.Attr and FileAttrs) = sr.Attr then
      begin
        ext := ExtractFileExt(sr.Name);
        if NOT ((sr.name = '.') or (sr.name = '..'))
          and ((ext = '.map') or (ext = '.exe')) then
          FileNameList.Add(sr.name);
      end;
    until FindNext(sr) <> 0;
    FindClose(sr);
  end;

  // Add any pin pad download files to list (so they can be copied to other terminals)
  SaveFileNameListCount := FileNameList.Count;
  path := '\Latitude\Update\Ingenico\';
  FileAttrs := faAnyFile and (not faDirectory);
  if (FindFirst(Path + '*.*', FileAttrs, sr) = 0) then
  begin
    repeat  // for each file in directory
      FileNameList.Add('Ingenico\' + sr.Name);
    until (FindNext(sr) <> 0);  // next file
    FindClose(sr);
  end;

  // first, copy all the update files to any other terminals
  if ThisTerminalNo = 1 then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from Terminal where TerminalNo <> :pTerminalNo');
      ParamByName('pTerminalNo').AsInteger := ThisTerminalNo;
      Open;
      while NOT EOF do
      begin
        for ndx := 0 to FileNameList.Count - 1 do
        begin
          fmPOSMsg.ShowMsg('', 'Copying ' + FileNameList.Strings[ndx] + ' To ' + Trim(FieldByName('TerminalName').AsString));
          CopyFile( PChar('\Latitude\Update\' + FileNameList.Strings[ndx]),
             PChar('\\' +  Trim(FieldByName('TerminalName').AsString) +
             '\' +  Trim(FieldByName('AppDrive').AsString)  +'\Latitude\Update\' + FileNameList.Strings[ndx]), False);
        end;
        next;
      end;
      Close;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end;

  // Download any new files available to Pin Pad device.
  UpdatePinPadFiles();

  // Remove any pin pad download files from file name list
  if (SaveFileNameListCount < FileNameList.Count) then
  begin
    for j := FileNameList.Count - 1 downto SaveFileNameListCount do
      FileNameList.Delete(j);
  end;

  // next figure out if anything important has to be updated
  // on the master, we might have to stop fuel, cat or credit


  DBUpdateName     := '';
  bDBUpdate        := False;
  bCatSrvr         := False;
  bCredit          := False;
  bCarWash         := False;

  bFuelProg        := False;

  bReceiptSrvr     := False;
  bPinPadSrvr      := False;  //20070116a
  bSysMgr          := False;
  bLatitude        := False;
  bPOSUpdate       := False;
  bMenuUpdate      := false;
  bButtonUpdate    := false;
  bMsgUpdate       := false;
  bSecurity        := False;
  bMOServer        := False;

  for ndx := 0 to FileNameList.Count - 1 do
  begin
    ext := ExtractFileExt(FileNameList.Strings[ndx]);
    if ext <> '.exe' then
      continue;
    ucname := Uppercase(FileNameList.Strings[ndx]);
    if ThisTerminalNo = MasterTerminalNo then
    begin
      if Pos('DBUPDATE', ucname) > 0 then
      begin
        DBUpdateName := FileNameList.Strings[ndx];   // save the name as it will
                                                           //    be unique to the build
        FileNameList.Strings[ndx] := '';
        bDBUpdate := True;
      end;


      if nCATInterfaceType > 0 then
      begin
        if Pos('CATSRVR', ucname) > 0 then
        begin
          FileNameList.Strings[ndx] := '';
          bCatSrvr := True;
        end;
      end;

      if (CreditHostReal(nCreditAuthType)) then
      begin
        if Pos('CREDITSERVER', ucname) > 0 then
        begin
          FileNameList.Strings[ndx] := '';
          bCredit := True;
        end;
      end;


      //cwa...
      case Setup.CarWashInterfaceType of
          CWSRV_UNITEC, CWSRV_PDQ :
            begin
              if Pos('CARWASH', ucname) > 0 then
              begin
                FileNameList.Strings[ndx] := '';
                bCarWash := True;
              end;
            end;
      end;//Case
      //...cwa

      case nFuelInterfaceType of
          1,2 :
            begin
              if Pos('FUELPROG', ucname) > 0 then
              begin
                FileNameList.Strings[ndx] := '';
                bFuelProg := True;
              end;
            end;
          3 :
            begin
              if Pos('FUELALLIED', ucname) > 0 then
              begin
                FileNameList.Strings[ndx] := '';
                //bFuelAllied := True;
              end;
            end;
      end;//Case
    end;

    if Pos('LATITUDEUPDATE', ucname) > 0 then
    begin
      FileNameList.Strings[ndx] := '';
      bPOSUpdate := True;
    end;

    if Pos('RECEIPTSRVR', ucname) > 0 then
    begin
      FileNameList.Strings[ndx] := '';
      bReceiptSrvr := True;
    end;

    //20070116a... (Added to detect and close PinPad server, if running)
    if bPinPadActive > 0 then
    begin
      if Pos('PINPADS', ucname) > 0 then
      begin
        FileNameList.Strings[ndx] := '';
        bPinPadSrvr := True;
      end;
    end;
    //...20070116a

    if Pos('SYSMGR', ucname) > 0 then
    begin
      FileNameList.Strings[ndx] := '';
      bSysMgr := True;
    end;

    if Pos('LATITUDE.', ucname) > 0 then
    begin
      FileNameList.Strings[ndx] := '';
      bLatitude := True;
    end;

    if Pos('SECSERVER.', ucname) > 0 then
    begin
      FileNameList.Strings[ndx] := '';
      bSecurity := True;
    end;

    if POS('MOSERVER.', ucname) > 0 then
    begin
      FileNameList.Strings[ndx] := '';
      bMOServer := True;
    end;

  end;

  if fileexists('\Latitude\Update\LatitudeMnu.txt') then
    bMenuUpdate := True;

  if fileexists('\Latitude\Update\LatitudeKyb.txt') then
    bButtonUpdate := True;

  if fileexists('\Latitude\Update\LatitudeMsg.txt') then
    bMsgUpdate := True;

  // now that we know what to update, first copy up anything else that might be in the
  // update directory

  if not DirectoryExists('\Latitude\SWBackup') then
    if not CreateDir('\Latitude\SWBackup') then
      raise Exception.Create('Cannot create \Latitude\SWBackup');

  for ndx := 0 to FileNameList.Count - 1 do
  begin
    if (FileNameList.Strings[ndx] > '') and (ExtractFileExt(FileNameList.Strings[ndx]) = '.exe') then
    begin
      fmPOSMsg.ShowMsg('', 'Installing ' + FileNameList.Strings[ndx] );
      //20070501b...
      if ((ThisTerminalNo <> MasterTerminalNo) and
          ((Pos('CATSRVR', ucname) > 0) or
           (Pos('FUELPROG', ucname) > 0))) then
      begin
        CopyUpdateFile( FileNameList.Strings[ndx] );
        SendFuelMessage(0, FS_STARTSERVER, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
      end
      else
      //...20070501b
        CopyUpdateFile( FileNameList.Strings[ndx] );
    end;
  end;

  if EODInProgress and (bLatitude or bReceiptSrvr) then
  begin
    fmPOSMsg.ShowMsg('', 'Waiting for EOD to Print' );
    for DelayTime := 1 to SleepTime do
    begin
      Application.ProcessMessages;
      fmPOSMsg.ShowMsg('', 'Completing EOD '+ inttostr((SleepTime-DelayTime) div 100) + ' Seconds Remaining');
      sleep(10);
    end;
  end;

  if bMenuUpdate then
  begin
    fmPOSMsg.ShowMsg('', 'Performing Menu Update' );
    if not POSDataMod.IBTransactionMenuUpdate.InTransaction then
      POSDataMod.IBTransactionMenuUpdate.StartTransaction;
    try
      with POSDataMod.IBQueryMenuUpdate do
      begin
        Close;SQL.Clear;
        SQL.Add('Update Terminal Set ReloadSetup = 1');
        ExecSQL;
        close;SQL.Clear;
        SQL.Add('Delete from Menu');
        ExecSQL;
        AssignFile(InFile,'\Latitude\Update\LatitudeMnu.txt');
        reset(InFile);
        while not System.EOF(InFile) do
        begin
          readln(InFile,InStrng);
          close;SQL.Clear;
          SQL.Add('Insert into Menu (MenuNo, Name, AutoClose) ');
          SQL.Add('Values(:pMenuNo, :pName, :pAutoClose)');
          parambyname('pMenuNo').AsString := ParseString(InStrng,1);
          parambyname('pName').AsString := ParseString(InStrng,2);
          parambyname('pAutoClose').AsString := ParseString(Instrng,3);
          ExecSQL;
        end;
        CloseFile(InFile);
      end;
      DeleteFile( '\Latitude\Update\LatitudeMnu.txt' );
      if POSDataMod.IBTransactionMenuUpdate.InTransaction then
        POSDataMod.IBTransactionMenuUpdate.Commit;
    except
      fmPOSMsg.ShowMsg('Menu Update Failed', '');
    end;
  end;

  if bButtonUpdate then
  begin
    fmPOSMsg.ShowMsg('', 'Performing Button Update' );
    if not POSDataMod.IBTransactionMenuUpdate.InTransaction then
      POSDataMod.IBTransactionMenuUpdate.StartTransaction;
    try
      with POSDataMod.IBQueryMenuUpdate do
      begin
        Close;SQL.Clear;
        SQL.Add('Update Terminal Set ReloadSetup = 1');
        ExecSQL;
        close;SQL.Clear;
        SQL.Add('Delete from TouchKybd');
        ExecSQL;
        AssignFile(InFile,'\Latitude\Update\LatitudeKyb.txt');
        Reset(Infile);
        while not System.Eof(InFile) do
        begin
          readln(InFile,InStrng);
          close;SQL.Clear;
          SQL.Add('Insert into TouchKybd (ALTNO, MENUNO, CODE, PRESET, ');
          SQL.Add('BTNCOLOR, BTNSHAPE, BTNFONT, BTNFONTCOLOR, BTNFONTSIZE, ');
          SQL.Add('BTNFONTBOLD, BTNLABEL, KEYVAL, MGRLOCK, RECTYPE) ');
          SQL.Add('Values(:pAltNo, :pMENUNO, :pCODE, :pPRESET, :pBTNCOLOR, ');
          SQL.Add(':pBTNSHAPE, :pBTNFONT, :pBTNFONTCOLOR, :pBTNFONTSIZE, ');
          SQL.Add(':pBTNFONTBOLD, :pBTNLABEL, :pKEYVAL, :pMGRLOCK, :pRECTYPE)');
          parambyname('pALTNO').AsString := ParseString(InStrng,1);
          parambyname('pMENUNO').AsString := ParseString(InStrng,2);
          parambyname('pCODE').AsString := ParseString(InStrng,3);
          parambyname('pPRESET').AsString := ParseString(InStrng,4);
          parambyname('pBTNCOLOR').AsString := ParseString(InStrng,5);
          parambyname('pBTNSHAPE').AsString := ParseString(InStrng,6);
          parambyname('pBTNFONT').AsString := ParseString(InStrng,7);
          parambyname('pBTNFONTCOLOR').AsString := ParseString(InStrng,8);
          parambyname('pBTNFONTSIZE').AsString := ParseString(InStrng,9);
          parambyname('pBTNFONTBOLD').AsString := ParseString(InStrng,10);
          parambyname('pBTNLABEL').AsString := ParseString(InStrng,11);
          parambyname('pKEYVAL').AsString := ParseString(InStrng,12);
          parambyname('pMGRLOCK').AsString := ParseString(InStrng,13);
          parambyname('pRECTYPE').AsString := ParseString(InStrng,14);
          ExecSQL;
        end;
        CloseFile(InFile);
        DeleteFile( '\Latitude\Update\LatitudeKyb.txt' );
        if POSDataMod.IBTransactionMenuUpdate.InTransaction then
          POSDataMod.IBTransactionMenuUpdate.Commit;
      end;
    except
      fmPOSMsg.ShowMsg('Button Update Failed', '');
    end;
  end;

  if bMsgUpdate then
  begin
    fmPOSMsg.ShowMsg('', 'Performing Message Update' );
    if not POSDataMod.IBTransactionMenuUpdate.InTransaction then
      POSDataMod.IBTransactionMenuUpdate.StartTransaction;
    try
      with POSDataMod.IBQueryMenuUpdate do
      begin
        Close;SQL.Clear;
        SQL.Add('Update Terminal Set ReloadSetup = 1');
        ExecSQL;
        close;SQL.Clear;
        SQL.Add('Delete from POPUpMsg');
        ExecSQL;
        AssignFile(InFile,'\Latitude\Update\LatitudeMsg.txt');
        Reset(Infile);
        while not System.Eof(InFile) do
        begin
          readln(InFile,InStrng);
          close;SQL.Clear;
          SQL.Add('Insert into POPUpMsg (MSGNO, MSGNAME, MSGTYPE, MSGSUNDAY, ');
          SQL.Add('MSGMONDAY, MSGTUESDAY, MSGWEDNESDAY, MSGTHURSDAY, MSGFRIDAY, ');
          SQL.Add('MSGSATURDAY, MSGTIMETYPE, MSGSTARTTIME, MSGSTOPTIME, MSGINTERVAL, ');
          SQL.Add('MSGHEADER, MSGLINE1, MSGLINE2, MSGLINE3, MSGLINE4, MSGLINE5, ');
          SQL.Add('MSGLINE6, MSGLINE7, MSGLINE8, MSGLINE9, MSGLINE10, MSGUSERID, ');
          SQL.Add('MSGDEPARTMENT) values (:pMSGNO, :pMSGNAME, :pMSGTYPE, :pMSGSUNDAY, ');
          SQL.Add(':pMSGMONDAY, :pMSGTUESDAY, :pMSGWEDNESDAY, :pMSGTHURSDAY, :pMSGFRIDAY, ');
          SQL.Add(':pMSGSATURDAY, :pMSGTIMETYPE, :pMSGSTARTTIME, :pMSGSTOPTIME, :pMSGINTERVAL, ');
          SQL.Add(':pMSGHEADER, :pMSGLINE1, :pMSGLINE2, :pMSGLINE3, :pMSGLINE4, :pMSGLINE5, ');
          SQL.Add(':pMSGLINE6, :pMSGLINE7, :pMSGLINE8, :pMSGLINE9, :pMSGLINE10, :pMSGUSERID, ');
          SQL.Add(':pMSGDEPARTMENT)');
          parambyname('pMSGNO').AsString := ParseString(InStrng,1);
          parambyname('pMSGNAME').AsString := ParseString(InStrng,2);
          parambyname('pMSGTYPE').AsString := ParseString(InStrng,3);
          parambyname('pMSGSUNDAY').AsString := ParseString(InStrng,4);
          parambyname('pMSGMONDAY').AsString := ParseString(InStrng,5);
          parambyname('pMSGTUESDAY').AsString := ParseString(InStrng,6);
          parambyname('pMSGWEDNESDAY').AsString := ParseString(InStrng,7);
          parambyname('pMSGTHURSDAY').AsString := ParseString(InStrng,8);
          parambyname('pMSGFRIDAY').AsString := ParseString(InStrng,9);
          parambyname('pMSGSATURDAY').AsString := ParseString(InStrng,10);
          parambyname('pMSGTIMETYPE').AsString := ParseString(InStrng,11);
          parambyname('pMSGSTARTTIME').AsDateTime := strtodatetime(ParseString(InStrng,12));
          parambyname('pMSGSTOPTIME').AsDateTime := strtodatetime(ParseString(InStrng,13));
          parambyname('pMSGINTERVAL').AsString := ParseString(InStrng,14);
          parambyname('pMSGHEADER').AsString := ParseString(InStrng,15);
          parambyname('pMSGLINE1').AsString := ParseString(InStrng,16);
          parambyname('pMSGLINE2').AsString := ParseString(InStrng,17);
          parambyname('pMSGLINE3').AsString := ParseString(InStrng,18);
          parambyname('pMSGLINE4').AsString := ParseString(InStrng,19);
          parambyname('pMSGLINE5').AsString := ParseString(InStrng,20);
          parambyname('pMSGLINE6').AsString := ParseString(InStrng,21);
          parambyname('pMSGLINE7').AsString := ParseString(InStrng,22);
          parambyname('pMSGLINE8').AsString := ParseString(InStrng,23);
          parambyname('pMSGLINE9').AsString := ParseString(InStrng,24);
          parambyname('pMSGLINE10').AsString := ParseString(InStrng,25);
          parambyname('pMSGUSERID').AsString := ParseString(InStrng,26);
          parambyname('pMSGDEPARTMENT').AsString := ParseString(InStrng,27);
          ExecSQL;
        end;
        CloseFile(InFile);
        DeleteFile( '\Latitude\Update\LatitudeMsg.txt' );
        if POSDataMod.IBTransactionMenuUpdate.InTransaction then
          POSDataMod.IBTransactionMenuUpdate.Commit;
      end;
    except
      fmPOSMsg.ShowMsg('Message Update Failed', '');
    end;
  end;

  if bDBUpdate then
  begin
    fmPOSMsg.ShowMsg('', 'Performing Database Update' );
    CopyUpdateFile( DBUpdateName );
    try
      WinExecAndWait32('\Latitude\' + DBUpdateName , SW_SHOWMINIMIZED);
      DeleteFile( '\Latitude\' + DBUpdateName );
    except
      fmPOSMsg.ShowMsg('DB Update Failed', '');
    end;
  end;
  if bPOSUpdate then
  begin
    fmPOSMsg.ShowMsg('', 'Updating Auto Update ' + IntToStr(i) );
    CopyUpdateFile( 'LatitudeUpdate.exe' );
  end;

  if bCATSrvr or bFuelProg then
  begin
    fmPOSMsg.ShowMsg('', 'Stopping Fuel Servers' );
    bCatStop := ShutdownApp('CAT Server', 'TfmCATServer', 'CATSrvr.exe');
    bFuelStop := ShutdownApp('Fuel Server', 'TfmFuelServer', 'FuelProg.exe');
    if (not bCATstop) or (not bFuelStop) then
    begin
      if (not bCATstop) then
      begin
        fmPOSMsg.ShowMsg('', 'Unable to stop CAT Server');
        UpdateExceptLog('Unable to stop CAT Server');
      end;
      if (not bFuelStop) then
      begin
        fmPOSMsg.ShowMsg('', 'Unable to stop Fuel Server');
        UpdateExceptLog('Unable to stop Fuel Server');
      end;
    end
    else
    begin
      if bCATSrvr then CopyUpdateFile( 'CATSrvr.exe' );
      if bFuelProg then CopyUpdateFile( 'FuelProg.exe' );
    end;
  end;

  if bCredit then
  begin
    fmPOSMsg.ShowMsg('', 'Stopping Credit Server' );
    ServerAppHandle := FindWindow('TfmCreditServer', nil);
    PostMessage(ServerAppHandle, WM_Close , 0, 0);
    if ShutDownApp('Credit Server', 'TfmCreditServer', 'CreditServer.exe') then
      CopyUpdateFile( 'CreditServer.exe' )
    else
    begin
      fmPOSMsg.ShowMsg('', 'Unable to stop Credit Server');
      UpdateExceptLog('Unable to stop Credit Server');
    end;


  end;

  (*if bBuypassCredit then
  begin
    fmPOSMsg.ShowMsg('', 'Updating Buypass Credit Server' );

    DCOMBuypassCredit.ForceCloseCredit;
    DCOMBuypassCredit := nil;
    i:= 1;
    Repeat
      fmPOSMsg.ShowMsg('', 'Updating Buypass Credit Server ' + IntToStr(i) );
      //cwe        ServerAppHandle := 0;
      ServerAppHandle := FindWindow('TfmCreditServer', nil);
      If (ServerAppHandle <> 0) Then
      Begin
        PostMessage(ServerAppHandle, WM_Close , 0, 0);
        For DelayTime:= 1 to 1000 do
          Application.ProcessMessages;
        Inc(i);
        sleep(2000);
      End
      else
        break;
    Until i > 10;
    sleep(5000);
    CopyUpdateFile( 'BuypassCredit.exe' );

  end;*)

  //cwa...
  if bCarWash then
  begin
    fmPOSMsg.ShowMsg('', 'Updating Car Wash Server' );
    try
      if CarwashEvents <> nil then
      begin
        CarwashEvents.Disconnect;
        CarwashEvents.Free;
        CarwashEvents := nil;
      end;
    except
    end;
    try
      //DCOMCarWash.ForceCloseCarWash;
      DCOMCarWash.CloseCarWash;
      DCOMCarWash := nil;
    except
    end;
    if ShutdownApp('Car Wash Server', 'TfmCarWashServer') then
      CopyUpdateFile( 'CarWash.exe' )
    else
    begin
      fmPOSMsg.ShowMsg('', 'Unable to stop Car Wash Server');
      UpdateExceptLog('Unable to stop Car Wash Server');
    end;


  end;
  //...cwa

  if bReceiptSrvr then
  begin
    fmPOSMsg.ShowMsg('', 'Updating Receipt Server');
    try
      try
        if ReceiptEvents <> nil then
        begin
          ReceiptEvents.Free;
          ReceiptEvents := nil;
        end;
      except;
      end;
      DCOMPrinter.StopServer;
      DCOMPrinter := nil;
    except;
    end;
    if ShutdownApp('Receipt Server', 'TfmReceiptServer', 'ReceiptSrvr.exe') then
      CopyUpdateFile( 'ReceiptSrvr.exe' )
    else
    begin
      fmPOSMsg.ShowMsg('', 'Unable to stop Receipt Server');
      UpdateExceptLog('Unable to stop Receipt Server');
    end;
  end;

  if bMOServer then
  begin
    fmPOSMsg.ShowMsg('', 'Updating MO Server' );
    ServerAppHandle := FindWindow('TMOSFrm', nil);
    PostMessage(ServerAppHandle, WM_Close , 0, 0);
    if ShutdownApp('MO Server','TMOSFrm') then
      CopyUpdateFile( 'MOServer.exe' )
    else
    begin
      fmPOSMsg.ShowMsg('', 'Unable to stop MO Server');
      UpdateExceptLog('Unable to stop MO Server');
    end;

  end;


  if bSysMgr then
  begin
    if ShutdownApp('System Manager', 'TfmMainPOSBO', 'SysMgr.exe') then
      CopyUpdateFile( 'SysMgr.exe' )
    else
    begin
      fmPOSMsg.ShowMsg('', 'Unable to stop System Manager');
      UpdateExceptLog('Unable to stop System Manager');
    end;
  end;

  if bLatitude then
  begin
    fmPOSMsg.ShowMsg('', 'Shutting down Latitude');
    //Added to close Receipt Server
    if not bReceiptSrvr then
    begin
      try
        try
          if ReceiptEvents <> nil then
          begin
            ReceiptEvents.Free;
            ReceiptEvents := nil;
          end;
        except
        end;
        DCOMPrinter.StopServer;
        DCOMPrinter := nil;
      except
      end;
      ShutdownApp('Receipt Server','TfmReceiptServer');
    end;
    //Added to close Receipt Server

    if assigned(Self.FFPCPostThread) then
      try
        Self.FFPCPostThread.Terminate;
        Self.FFPCPostThread.Destroy;
      except
      end;
    Self.FFPCPostThread := nil;

    if assigned(Self.PPTrans) then
    begin
      Self.PPTrans.PINPadClose;
      while Self.PPTrans.PinPadOnLine do
        Application.ProcessMessages;
    end;

    SyncLogs := True;
    UpdateZLog(''); // Flushing Logs

    fmPOSMsg.ShowMsg('', 'Updating Latitude POS ' );
    StartProcess('\Latitude\LatitudeUpdate.exe');
    bPOSForceClose := True;

    Application.Terminate;
  end
  else
  begin
    UpdateZLog('Not restarting, so restarting apps');
    if bReceiptSrvr then
    begin
      fmPOSMsg.ShowMsg('', 'Reconnecting Receipt Server' );
      ReconnectPrinter('SoftwareUpdate', '', 1);
    end;

    //20070116a... (Added to detect and close PinPad server, if running)
    if bPinPadSrvr then
    begin
      fmPOSMsg.ShowMsg('', 'Reconnecting PinPad Server' );
      ReconnectPinPad('SoftwareUpdate');
    end;
    //...20070116a

    if bFuelProg or bCatSrvr then
    begin
      fmPOSMsg.ShowMsg('', 'Reconnecting Fuel Server' );
      ConnectFuelServer;
    end;

    if bCredit then
    begin
      fmPOSMsg.ShowMsg('', 'Reconnecting Credit Server' );
      ConnectCreditServer;
    end;

    //cwa...
    if bCarWash then
    begin
      fmPOSMsg.ShowMsg('', 'Reconnecting Car Wash Server' );
      ConnectCarWashServer();
    end;
    //...cwa

    if Setup.MOSystem then
    begin
      fmPOSMsg.ShowMsg('', 'Reconnecting Money Order Server');
      ConnectMOServer(False);
    end;

    if bCATSrvr then
    begin
      fmPOSMsg.ShowMsg('', 'Reconnecting CAT Server' );
      SendFuelMessage( 0, FS_STARTSERVER, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);  //20070501b (change FS_RESETCAT to FS_STARTSERVER)
    end;

  end;

  FileNameList.Free;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CopyUpdateFile
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: UpdateFileName : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.CopyUpdateFile(UpdateFileName : string);
var
  mapfn : string;
begin
  mapfn := ChangeFileExt(UpdateFileName, '.map');
  fmPOSMsg.ShowMsg('', 'Saving Prior Version ' + UpdateFileName);
  if FileExists('\Latitude\' + UpdateFileName) then
    CopyFile( PChar('\Latitude\' + UpdateFileName),
      PChar('\Latitude\SWBackUp\' + UpdateFileName + 'sav' + FormatDateTime('yymmdd', Now)), False);
  if FileExists('\Latitude\' + mapfn) then
    CopyFile( PChar('\Latitude\' + mapfn),
      PChar('\Latitude\SWBackUp\' + mapfn + 'sav' + FormatDateTime('yymmdd', Now)), False);

  fmPOSMsg.ShowMsg('', 'Removing Prior Version ' + UpdateFileName);

  if not DeleteFile( '\Latitude\' + UpdateFileName ) then
  begin
    fmPOSMsg.ShowMsg('', 'Failed to Delete ' + UpdateFileName);
    UpdateExceptLog('Failed to Delete ' + UpdateFileName);
    sleep(500);
  end;
  if not DeleteFile( '\Latitude\' + mapfn ) then
  begin
    fmPOSMsg.ShowMsg('', 'Failed to Delete ' + mapfn);
    UpdateExceptLog('Failed to Delete ' + mapfn);
    sleep(500);
  end;

  fmPOSMsg.ShowMsg('', 'Installing New Version ' + UpdateFileName);
  if CopyFile(PChar('\Latitude\Update\' + UpdateFileName),
    PChar('\Latitude\' + UpdateFileName), False) = false then
  begin
    fmPOSMsg.ShowMsg('', 'Update Failed ' + UpdateFileName);
    UpdateExceptLog('Update Failed:  ' + UpdateFileName );
    sleep(3000);
  end
  else
  begin
    fmPOSMsg.ShowMsg('', 'Removing Update File ' + UpdateFileName);
    DeleteFile( '\Latitude\Update\' + UpdateFileName );
    if CopyFile(Pchar('\Latitude\Update\' + mapfn),
      PChar('\Latitude\' + mapfn), False) = false then
    begin
      fmPOSMsg.ShowMsg('', 'Update Failed ' + mapfn);
      UpdateExceptLog('Update Failed: ' + mapfn);
      sleep (1000);
    end
    else
      DeleteFile('\Latitude\Update\' + mapfn);
    UpdateExceptLog('Update Complete:  ' + UpdateFileName );
  end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyASU
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyASU(const ResumeMode : TResumeKeyMode);
var
  c : integer;
  CCMsg : string;
  CWMsg : string;
  Dep : boolean;
begin
  if (ResumeMode = mResumeKeyInit) then
  begin
    if (ThisTerminalNo <> MasterTerminalNo) then
      POSError('This Function Must Be Run From The Master Terminal')
    else if (NOT SoftwareUpdatePending()) then
      POSError('There Are No Software Updates To Apply')
    else
      QueryLoggedOnInfo(LU_RET_ASU, 0);
    exit;
  end;

  Dep := DependentSoftwareUpdatePending();

  if ((ResumeMode = mResumeKeyTerminalNotClosed) and Dep) then
  begin
    POSError('Please Log-Off Other Terminals Before Applying Software Update');
    exit;
  end;

  // If no exit above, then this procedure was called after checking what other users logged in.

  PopUpMsgTimer.Enabled := False;

  fmPOSMsg.ShowMsg('Applying Software Update', '');

  {$IFDEF ESF_NET}//20070515a
  if not EODInProgress then
  {$ENDIF}
  begin
    if Dep then
    begin
    CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_PAUSECREDIT));
    SendCreditMessage(CCMsg);
  end;
  end;

  if Dep then
  begin
  CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_PAUSE_SERVER));
  SendCarWashMessage(CWMsg);
  end;

  if Dep then
  begin
  SendFuelMessage(0, PMP_PAUSEALL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );

  for c := 1 to 1000 do
    Application.ProcessMessages;

  for c := 1 to 50 do
    begin
      Application.ProcessMessages;
      sleep(1);
    end;

  for c := 1 to 1000 do
    Application.ProcessMessages;
  end;


  ApplySoftwareUpdate;

  if NOT bPOSForceClose then
    begin
      {$IFDEF ESF_NET}//20070515a
      if not EODInProgress then
      {$ENDIF}
      begin
        if Dep then
        begin
        CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_RESUMECREDIT));
        SendCreditMessage(CCMsg);
      end;
      end;

      if Dep then
      begin
      CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_RESUME_SERVER));
      SendCarWashMessage(CWMsg);

      SendFuelMessage(0, PMP_RESUMEALL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
      end;

      fmPOSMsg.Close;

      ProcesskeyUSO;
      PopUpMsgTimer.Enabled := True;
    end;


end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PostItemSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
function TfmPOS.PostItemSale : pSalesData;
var
  CurSaleData : pSalesData;
begin

  if nModifierValue > 0 then
  begin
    if not POSDataMod.IBDb.TestConnected then
      OpenTables(False);
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBPLUModQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('Select * from PLUMod where PLUNo = :pPLUNo and PLUModifier = :pPLUModifier');
      ParamByName('pPLUNo').AsCurrency       := nNumber;
      ParamByName('pPLUModifier').AsCurrency := nModifierValue;
      Open;
      if RecordCount > 0 then
      begin
        PLUModPLUNo := nNumber;
        PLUModPLUModifier := nModifierValue;
        PLUModPLUPRICE	:= fieldbyname('PLUPrice').Ascurrency;
        PLUModPLUMODIFIERGROUP:= fieldbyname('PLUModifierGroup').AsCurrency;
        {$IFDEF PLU_MOD_DEPT}
        PLUModDeptNo := fieldbyname('DeptNo').AsInteger;
        PLUModSplitQty := fieldbyname('SplitQty').AsInteger;                     //20060717a
        PLUModSplitPrice := fieldbyname('SplitPrice').AsCurrency;                //20060717a
        {$ENDIF}
        close;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
      end
      else
      begin
        Close;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        POSError('Invalid PLU Modifier');
        Result := nil;
        exit;
      end;
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBModifierQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select * from Modifier where ModifierGroup = :pModifierGroup and ModifierNo = :pModifierNo');
        ParamByName('pModifierGroup').AsCurrency := PLUModPLUModifierGroup;
        ParamByName('pModifierNo').AsInteger     := nModifierValue;
        Open;
        if RecordCount > 0 then
        begin
          ModMODIFIERGROUP:= fieldbyname('ModifierGroup').AsCurrency;
          ModMODIFIERNO	:= fieldbyname('ModifierNo').Asinteger;
          ModMODIFIERNAME := fieldbyname('ModifierName').AsString;
          ModMODIFIERVALUE := fieldbyname('ModifierValue').AsInteger;
          ModMODIFIERDEFAULT:= fieldbyname('ModifierDefault').Asinteger;
        end;
        close;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
    end;
  end;
  if SaleState = ssNoSale then
    AssignTransNo;

  if nModifierValue > 0 then
  begin
   nAmount := PLUModPLUPrice;
  {$IFDEF PLU_MOD_DEPT}
   PLU.DEPTNO := PLUModDeptNo;
   PLU.SPLITQTY := PLUModSplitQty;                                                //20060717a
   PLU.SPLITPRICE := PLUModSplitPrice;                                            //20060717a
  {$ENDIF}
  end
  else
  begin
    nAmount := Plu.Price;
  end;

  if PLU.Subtracting then
    nAmount := nAmount * -1;

  nExtAmount := POSRound(nAmount * nQty, 2);

  SaleState := ssSale;
  sLineType := 'PLU';
  if lbReturn.Visible = True then
  begin
    sSaleType := 'Rtrn';
    If nQty > 0 then      //20060713b //GMM:  added to correct problem with return of linked plus
    begin
      nQty := nQty * -1;
      nExtAmount := nExtAmount * -1;
    end;
  end
  else
    sSaleType := 'Sale';

  CurSaleData := AddSaleList;
  PoleMdse(CurSaleData, SaleState);
  ComputeSaleTotal;
  {$IFDEF PDI_PROMOS}
  CheckForPDIAdjustment;
  {$ELSE}
  CheckForAdjustment(CurSaleData);
  {$ENDIF}
  {$IFDEF PLU_MOD_DEPT}
  if nModifierValue > 0 then          //GMM:  Added to force main menu after default modifier selection
  begin
    DisplayMenu(0);
    nModifierValue := 0;
  end;
  {$ENDIF}
  UpdateZLog('PostItemSale - end');
  Result := CurSaleData;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.AddSaleList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
function TfmPOS.AddSaleList() : pSalesData;
var
  j : integer;
  CurSaleData : pSalesData;
begin
  New(CurSaleData);
  ZeroMemory(CurSaleData, sizeof(TSalesData));
  CurSaleData^.SeqNumber := CurSaleList.Count + 1;
  CurSaleData^.LineType := sLineType;    {DPT, PLU, }
  CurSaleData^.SaleType := sSaleType;    {Sale, Void, Rtrn, VdVd, VdRt}

  CurSaleData^.PumpNo := 0;
  CurSaleData^.FuelSaleID := 0;

  CurSaleData^.TaxNo   := 0;   // Init Tax Stuff
  CurSaleData^.TaxRate := 0;
  CurSaleData^.Taxable := 0;
  CurSaleData^.Discable := False;
  CurSaleData^.FoodStampable := False;
  CurSaleData^.FoodStampApplied := 0;

  CurSaleData^.WEXCode := 0;
  CurSaleData^.PHHCode := 0;
  CurSaleData^.IAESCode := 0;
  CurSaleData^.VoyagerCode := 0;

  CurSaleData^.PLUModifier  := 0;
  CurSaleData^.PLUModifierGroup  := 0;
  CurSaleData^.DeptNo  := 0;
  CurSaleData^.VendorNo  := 0;
  CurSaleData^.ProdGrpNo  := 0;
  CurSaleData^.LinkedPLUNo  := 0;
  CurSaleData^.SplitQty  := 0;
  CurSaleData^.SplitPrice  := 0;
  CurSaleData^.LinkedPLUNo := 0;
  CurSaleData^.AutoDisc := False;
  CurSaleData^.QtyUsedForSplitOrMM := 0;
  //XMD
  CurSaleData^.SavDiscAmount := 0;
  CurSaleData^.SavDiscable := 0;
  //XMD
  CurSaleData^.NeedsActivation := False;
  CurSaleData^.MODocNo := '';
  if genSeqLink then
  begin
    CurSaleData^.SeqLink := CurSaleData^.SeqNumber;
    nSeqLink := CurSaleData^.SeqNumber;
    genSeqLink := False;
  end
  else
    CurSaleData^.SeqLink := nSeqLink;
  if sLineType = 'DPT' then
  begin
    CurSaleData^.Number      := Dept.DeptNo;
    CurSaleData^.DeptNo      := Dept.DeptNo;
    CurSaleData^.NeedsActivation := (Dept.DeptNo = Setup.GIFTCARDDEPTNO);
    CurSaleData^.Name        := Dept.DeptName;
    CurSaleData^.TaxNo       := Dept.TaxNo;
    CurSaleData^.Discable    := Dept.DISC;
    CurSaleData^.FoodStampable  := Dept.FS;
    CurSaleData^.mediarestrictioncode := Dept.mediarestrictioncode;

    CurSaleData^.WEXCode     := Dept.WEXCode;
    CurSaleData^.PHHCode     := Dept.PHHCode;
    CurSaleData^.IAESCode    := Dept.IAESCode;
    CurSaleData^.VoyagerCode := Dept.VoyagerCode;
    {$IFDEF ODOT_VMT}
    CurSaleDAta^.VMTReceiptData := Dept.VMTReceiptData;
    {$ENDIF}
  end
  else if sLineType = 'BNK' then
  begin
    CurSaleData^.Number   := BankBankNo;
    CurSaleData^.Name     := BankName;
    CurSaleData^.Discable := False;
  end
  else if sLineType = 'FUL' then
  begin
    CurSaleData^.Number      := Dept.DeptNo;
    CurSaleData^.Name        := 'Pump# ' + IntToStr(nPumpNo) + ' ' + Dept.DeptName;
    CurSaleData^.PumpNo      := nPumpNo;
    CurSaleData^.FuelSaleID  := nPumpSaleID;
    CurSaleData^.TaxNo       := Dept.TaxNo;
    CurSaleData^.Discable    := Dept.DISC;
    CurSaleData^.FoodStampable  := Dept.FS;
    CurSaleData^.WEXCode     := Dept.WEXCode;
    CurSaleData^.PHHCode     := Dept.PHHCode;
    CurSaleData^.IAESCode    := Dept.IAESCode;
    CurSaleData^.VoyagerCode := Dept.VoyagerCode;
    CurSaleData^.mediarestrictioncode := Dept.mediarestrictioncode;
  end
  else if sLineType = 'PPY' then
  begin
    CurSaleData^.Number     := 0;
    CurSaleData^.Name       := 'Pump# ' + IntToStr(nPumpNo) + ' Fuel Prepay';
    CurSaleData^.PumpNo     := nPumpNo;
    CurSaleData^.Discable   := True;
    CurSaleData^.mediarestrictioncode := MRC_FUEL;
  end
  else if sLineType = 'PRF' then
  begin
    CurSaleData^.Number     := 0;
    CurSaleData^.Name       := 'Pump# ' + IntToStr(nPumpNo) + ' Prepay Rfnd';
    CurSaleData^.PumpNo     := nPumpNo;
    CurSaleData^.FuelSaleID := nPumpSaleID;
    CurSaleData^.Discable   := True;
    CurSaleData^.mediarestrictioncode := MRC_FUEL;
  end
  else if sLineType = 'DSC' then
  begin
    CurSaleData^.Number         := nDiscNo;
    CurSaleData^.Name           := DisName;
    CurSaleData^.SavDiscable    := curSale.nDiscountableTl;
    CurSaleData^.SavDiscAmount  := nDiscAmount ;
    CurSaleData^.SavDiscType    := nDiscType;
    CurSaleData^.Discable       := False;
    if nDiscNo = Setup.SplitDisc then
    begin
      CurSaleData^.AutoDisc       := True;
      CurSaleData^.Name           := sDiscName;
    end;
  end
  else if sLineType = 'MXM' then
  begin
    CurSaleData^.Number         := nDiscNo;
    CurSaleData^.Name           := sDiscName;
    CurSaleData^.SavDiscable    := curSale.nDiscountableTl;
    CurSaleData^.SavDiscAmount  := nDiscAmount ;
    CurSaleData^.Discable       := False;
    CurSaleData^.AutoDisc       := True;
  end
  else if sLineType = 'PLU' then
  begin
    CurSaleData^.Number  := PLU.PluNo;
    if nModifierValue > 0 then
    begin
      CurSaleData^.Name             := ModModifierName + ' ' + PLU.Name;
      CurSaleData^.PLUModifier      := PLUModPLUModifier;
      CurSaleData^.PLUModifierGroup := PLUModPLUModifierGroup;
    end
    else
      CurSaleData^.Name      := PLU.Name;
    CurSaleData^.TaxNo       := PLU.TaxNo;
    CurSaleData^.Discable    := PLU.DISC;
    CurSaleData^.FoodStampable  := PLU.FS;
    CurSaleData^.WEXCode     := Dept.WEXCode;
    CurSaleData^.PHHCode     := Dept.PHHCode;
    CurSaleData^.IAESCode    := Dept.IAESCode;
    CurSaleData^.VoyagerCode := Dept.VoyagerCode;
    CurSaleData^.LinkedPLUNo := nLinkedPLUNo;
    CurSaleData^.DeptNo      := PLU.DeptNo;
    CurSaleData^.VendorNo    := PLU.VendorNo;
    CurSaleData^.ProdGrpNo   := PLU.ProdGrpNo;
    CurSaleData^.SplitQty    := PLU.SplitQty;
    CurSaleData^.SplitPrice  := PLU.SplitPrice;
    CurSaleData^.ItemNo      := PLU.ITEMNO;
    CurSaleData^.NeedsActivation := PLU.NeedsActivation;
    CurSaleData^.CCHost      := PLU.cchost;
    if Dept.mediarestrictioncode <> 0 then
    begin
      if PLU.mediarestrictioncode <> 0 then
        CurSaleData^.mediarestrictioncode := Dept.mediarestrictioncode and PLU.mediarestrictioncode
      else
        CurSaleData^.mediarestrictioncode := Dept.mediarestrictioncode;
    end
    else
    begin
      if PLU.mediarestrictioncode <> 0 then
        CurSaleData^.mediarestrictioncode := PLU.mediarestrictioncode
      else
        CurSaleData^.mediarestrictioncode := MRC_GENERAL;
    end;
  end;

  if sLineType = 'FUL' then
  begin
    if sSaleType = 'Void' then
    begin
      CurSaleData^.Qty      := nPumpVolume;
      CurSaleData^.Price    := nPumpAmount;
      CurSaleData^.ExtPrice := nExtAmount;

      CurSaleData^.Qty := CurSaleData^.Qty * -1;
      CurSaleData^.ExtPrice := CurSaleData^.ExtPrice * -1;
      nExtAmount := nExtAmount * -1;
    end
    else
    begin
      CurSaleData^.Qty := nPumpVolume;
      CurSaleData^.Price := nPumpUnitPrice;
      CurSaleData^.ExtPrice := nPumpAmount;
      nExtAmount := nPumpAmount;
    end;
  end
  else if sLineType = 'PLU' then
  begin
    CurSaleData^.Qty := nQty;
    CurSaleData^.Price := nAmount;
    CurSaleData^.ExtPrice := nExtAmount;
  end
  //XMD
  else if sLineType = 'XMD' then
  begin
    CurSaleData^.Name           := 'Fuel Discount';
    CurSaleData^.Number         := nXMDCode;
    CurSaleData^.Qty            := nQty - Frac(nQty);
    CurSaleData^.Price          := nAmount;
    nExtAmount                  := nAmount * CurSaleData^.Qty;
    CurSaleData^.ExtPrice       := nExtAmount;
    CurSaleData^.Discable       := False;
  end
  //XMD
  //DSG
  else if sLineType = 'DSG' then
  begin
    CurSaleData^.Name           := Copy(trim('Card Fuel Discount'),1,20);
    CurSaleData^.Number         := nDiscNo;
    CurSaleData^.Qty            := nQty;//nQty - Frac(nQty);
    CurSaleData^.Price          := nAmount;
    nExtAmount                  := nAmount * CurSaleData^.Qty;
    CurSaleData^.ExtPrice       := nExtAmount;
    CurSaleData^.Discable       := False;
    CurSaleData^.SavDiscAmount  := nAmount ;
    CurSaleData^.SavDiscType    := nDiscType;
    CurSaleData^.Discable       := False;
  end
  //DSG
  {$IFDEF CASH_FUEL_DISC}
  else if sLineType = 'DS$' then
  begin
    CurSaleData^.Name           := 'Cash Fuel Discount';  // max of 20 characters
    CurSaleData^.Number         := nDiscNo;
    CurSaleData^.Qty            := nQty;//nQty - Frac(nQty);
    CurSaleData^.Price          := nAmount;
    nExtAmount                  := nAmount * CurSaleData^.Qty;
    CurSaleData^.ExtPrice       := nExtAmount;
    CurSaleData^.Discable       := False;
    CurSaleData^.SavDiscAmount  := nAmount ;
    CurSaleData^.SavDiscType    := nDiscType;
    CurSaleData^.Discable       := False;
  end
  {$ENDIF}
  {$IFDEF ODOT_VMT}
  else if sLineType = 'DSV' then
  begin
    CurSaleData^.Name           := 'State Tax Discount';  // (default value - should be overwritten below) max of 20 characters
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      Close();
      SQL.Clear;
      SQL.Add('SELECT * FROM Disc where RecType = :pRecType and DiscNo = :pDiscNo');
      ParamByName('pDiscNo').AsInteger := nDiscNo;
      ParamByName('pRecType').AsString := 'F';
      Open();
      if RecordCount > 0 then
        CurSaleData^.Name           := FieldByName('Name').AsString;  // max of 20 characters
      Close();
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
    CurSaleData^.Number         := nDiscNo;
    CurSaleData^.Qty            := nQty;//nQty - Frac(nQty);
    CurSaleData^.Price          := nAmount;
    nExtAmount                  := nAmount * CurSaleData^.Qty;
    CurSaleData^.ExtPrice       := nExtAmount;
    CurSaleData^.Discable       := False;
    CurSaleData^.SavDiscAmount  := nAmount ;
    CurSaleData^.SavDiscType    := nDiscType;
    CurSaleData^.Discable       := False;
  end
  {$ENDIF}
  {$IFDEF FF_PROMO}
  else if sLineType = 'FFP' then   // Fuel First Promotion
  begin
    // Dummy zero-amount entry on sales list to indicate Fuel First award.
    CurSaleData^.Number         := nDiscNo;
    CurSaleData^.Name           := 'See Coupon Receipt';
    CurSaleData^.SavDiscType    := '';
    CurSaleData^.Qty            := 0.0;
    CurSaleData^.Price          := 0.0;
    CurSaleData^.ExtPrice       := 0;
    CurSaleData^.PumpNo         := nPumpNo;
    CurSaleData^.HoseNo         := 0;
  end
  {$ENDIF}
  else
  begin
    CurSaleData^.Qty   := nQty;
    CurSaleData^.Price := nAmount;
    {$IFDEF PDI_PROMOS}
    if CurSaleData^.LineType = 'DSC' then
      nExtAmount := nAmount
    else
    {$ENDIF}
    nExtAmount := nAmount * nQty;
    CurSaleData^.ExtPrice := nExtAmount;
  end;

  CurSaleData^.LineVoided     := False;
  CurSaleData^.CCAuthCode     := '';
  CurSaleData^.CCApprovalCode := '';
  CurSaleData^.CCDate         := '';
  CurSaleData^.CCTime         := '';
  CurSaleData^.CCCardNo       := '';
  CurSaleData^.CCPartialTend  := False;
  {$IFDEF FUEL_FIRST}
  try
    if (iCATCardType > 0) then
      CurSaleData^.CCCardType     := Format('%2.2d', [iCATCardType])
    else
      CurSaleData^.CCCardType     := '';
  except
    CurSaleData^.CCCardType     := '';
  end;
  iCATCardType := 0;
  {$ELSE}
  CurSaleData^.CCCardType     := '';
  {$ENDIF}
  //cwa...
//  CurSaleData^.CCCardName     := '';
  CurSaleData^.CCCardName     := sCarwashAccessCode;  // normally '' (unless a carwash purchase)
  //...cwa
  //cwf...
//  CurSaleData^.CCExpDate      := '';
  CurSaleData^.CCExpDate      := sCarwashExpDate;  // normally '' (unless a carwash purchase)
  //...cwf
  //Build 23
  sCarwashAccessCode          := '';
  sCarwashExpDate             := '';
  //Build 23
  CurSaleData^.CCBatchNo      := '';
  CurSaleData^.CCSeqNo        := '';
  CurSaleData^.CCEntryType    := '';
  CurSaleData^.CCVehicleNo    := '';
  CurSaleData^.CCOdometer     := '';
  //Build 18
  CurSaleData^.PriceOverridden := false;
  //Build 18

  //bp...
  for j := low(CurSaleData^.CCPrintLine) to high(CurSaleData^.CCPrintLine) do
    CurSaleData^.CCPrintLine[j] := '';
  if KioskOrderNo <> 0 then
    CurSaleData^.CCPrintLine[1]   := 'K' + IntToStr(KioskOrderNo);
  CurSaleData^.CCBalance1     := UNKNOWN_BALANCE;
  CurSaleData^.CCBalance2     := UNKNOWN_BALANCE;
  CurSaleData^.CCBalance3     := UNKNOWN_BALANCE;
  CurSaleData^.CCBalance4     := UNKNOWN_BALANCE;
  CurSaleData^.CCBalance5     := UNKNOWN_BALANCE;
  CurSaleData^.CCBalance6     := UNKNOWN_BALANCE;
  //...53o
  //...lk1
  CurSaleData^.CCRequestType  := RT_UNKNOWN;
  {$IFDEF FUEL_FIRST}
  CurSaleData^.CCAuthID := iCATAuthID;
  iCATAuthID := 0;
  {$ELSE}
  CurSaleData^.CCAuthID   := CC_AUTHORIZER_UNKNOWN;
  {$ENDIF}
  //...bp
  if fmMO.MOLine(CurSaleData) and (CurSaleData^.Qty < 0) then
    CurSaleData^.MODocNo := MOInfo.SerialNo;
    
  if ((CurSaleData^.NeedsActivation) and
      (CurSaleData^.Qty > 0) and           // No need for balance check on de-activations
      (ActivationProductData.ActivationCardType = CT_GIFT)) then
  begin
    CurSaleData^.Name := EncodeGiftCardInfoInDeptName(CurSaleData);
    CurSaleData^.ActivationState := asWaitBalance
  end
  else if CurSaleData^.NeedsActivation then
    CurSaleData^.ActivationState := asActivationNeeded
  else
    CurSaleData^.ActivationState := asActivationDoesNotApply;
  CurSaleData^.ActivationTimeout := 0;
  CurSaleData^.ActivationTransNo := 0;
  CurSaleData^.LineID := GetLineID();
  CurSaleData^.ccPIN := '';
  CurSaleList.Capacity := CurSaleList.Count;
  fmPOS.AddSalesListBeforeMedia(CurSaleData);
  //Gift
  {$IFDEF FUEL_PRICE_ROLLBACK}
  DisplaySaleList(CurSaleData, False);
  {$ELSE}
  DisplaySaleList(CurSaleData);
  {$ENDIF}
  Result := CurSaleData;
end;  //auth


{$IFDEF PDI_PROMOS}
function GetModifierName(ModifierGroupNo : currency; ModifierNo : integer) : string;
var
  ModifierName : string;

begin
  if ModifierGroupNo <= 0 then
    ModifierName := 'EACH'
  else
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBModifierQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT MODIFIERNAME FROM MODIFIER ');
      SQL.Add('WHERE MODIFIERGROUP = :pModifierGroup AND MODIFIERNO = :pModifierNo');
      ParamByName('pModifierGroup').AsCurrency := ModifierGroupNo;
      ParamByName('pModifierNo').AsInteger := ModifierNo;
      Open;
      if not EOF then
        ModifierName := trim(fieldbyname('MODIFIERNAME').AsString);
      Close;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end;

  GetModifierName := ModifierName;
end;

procedure TfmPOS.CheckForPDIAdjustment();
var
  CurrentTime : string;
  CurrentDate : string;
  DayAbbr : string;
  PromoMatched : boolean;
  PromoListsMatched : boolean;
  PromoNoBeingChecked : string;
  PromoNameBeingChecked : string;
  PromoListtoCheck : integer;
  PromoMatchQty : integer;

  function PromotionListMatch (ListNo : integer; MatchQty : integer) : boolean;
  var
    MatchResult : boolean;
    SD : pSalesData;
    SDInner : pSalesData;
    ItemCount : integer;
    ItemCountInner : integer;
    ItemPLU : currency;
    ItemModifierName : String;
    ItemQty : integer;

    function ItemInList (ListNo : integer; ItemNo : currency; ItemModifierName : string) : boolean;
    var
      InListResult : boolean;

    begin
      InListResult := false;
      if not POSDataMod.IBTempTrans2.InTransaction then
        POSDataMod.IBTempTrans2.StartTransaction;
      with POSDataMod.IBTempQuery2 do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT LISTNAME FROM PROMOLISTS ');
        SQL.Add('WHERE LISTNO = :pListNo AND ITEMNO = :pItemNo AND MODIFIERNAME = :pModifierName');
        ParamByName('pListNo').AsInteger := ListNo;
        ParamByName('pItemNo').AsCurrency := ItemNo;
        ParamByName('pModifierName').AsString := ItemModifierName;
        Open;
        if not EOF then
          InListResult := true;
        Close;
      end;
      if POSDataMod.IBTempTrans2.InTransaction then
        POSDataMod.IBTempTrans2.Commit;

      ItemInList := InListResult;
    end;

  begin
    MatchResult := false;
    ItemCount := 0;
    while ((ItemCount < CurSaleList.Count) and (not MatchResult)) do
    begin
      SD := CurSaleList.Items[ItemCount];
      if (SD^.LineType = 'PLU') and (SD^.SaleType = 'Sale') and (not SD^.LineVoided) then
      begin
        ItemPlu := SD^.Number;
        ItemQty := StrtoInt(CurrtoStr(SD^.Qty));
        ItemModifierName := GetModifierName(SD^.PLUModifierGroup, SD^.PLUModifier);
        if ItemInList(ListNo, ItemPLU, ItemModifierName) then
        begin
          ItemCountInner := ItemCount + 1;
          while ItemCountInner < CurSaleList.Count do
          begin
             SDInner := CurSaleList.Items[ItemCountInner];
             if (ItemInList(ListNo,SDInner^.Number,GetModifierName(SDInner^.PLUModifierGroup, SDInner^.PLUModifier))) and (SDInner^.LineType = 'PLU') and (SDInner^.SaleType = 'Sale') and (not SDInner^.LineVoided) then
               ItemQty := ItemQty + StrtoInt(CurrtoStr(SDInner^.Qty));
             inc(ItemCountInner);
          end;
          if ItemQty >= MatchQty then
            MatchResult := true;
        end;
      end;
      inc(ItemCount);
    end;
    PromotionListMatch := MatchResult;
  end;

  procedure ApplyPDIDiscount(PromoName : string; PromoNo : string);

    procedure RemovePDIDiscounts(PromoNo : string; ListNo : integer; NFSTotal : currency; FSTotal : currency; PromoMatches : currency);
    var
      FirstFound : boolean;
      ItemCount : integer;
      SD : pSalesData;
      SaveExtPrice : currency;
      LocalNFSTotal : currency;
      LocalFSTotal : currency;
    begin
      if not POSDataMod.IBTempTrans2.InTransaction then
        POSDataMod.IBTempTrans2.StartTransaction;
      with POSDataMod.IBTempQuery2 do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT PR.LISTNO, MATCHQTY, PROMOTYPE, PROMOVALUE, ITEMNO, MODIFIERNAME FROM PROMOTIONS PR ');
        SQL.Add('INNER JOIN PROMOLISTS PL ON PR.LISTNO = PL.LISTNO ');
        SQL.Add('WHERE PROMONO = :pPromoNo AND LISTNO = :pListNo AND ( ');
        FirstFound := false;
        for ItemCount := 0 to CurSaleList.Count -1 do
        begin
          SD := CurSaleList.Items[ItemCount];
          if (SD^.LineType = 'PLU') and (SD^.SaleType = 'Sale') and (not SD^.LineVoided) then
            if not FirstFound then
            begin
              SQL.Add(' ((ITEMNO = ' + CurrtoStr(SD^.Number) + ') AND (MODIFIERNAME = ''' + GetModifierName(SD^.PLUModifierGroup, SD^.PLUModifier) + ''')) ' );
              FirstFound := true;
            end
            else
              SQL.Add(' OR ((ITEMNO = ' + CurrtoStr(SD^.Number) + ') AND (MODIFIERNAME = ''' + GetModifierName(SD^.PLUModifierGroup, SD^.PLUModifier) + ''')) ' )
        end;
        SQL.Add(') ');
        SQL.Add('ORDER BY PR.LISTNO, ITEMNO ');
        ParamByName('pPromoNo').AsCurrency := StrtoCurr(PromoNo);
        ParamByName('pListNo').AsInteger := ListNo;
        Open;
        LocalNFSTotal := NFSTotal;
        LocalFSTotal := FSTotal;
        while ((not EOF) and ((LocalFSTotal >0) or (LocalNFSTotal > 0))) do
        begin
          for ItemCount := 0 to CurSaleList.Count -1 do
          begin
            SD := CurSaleList.Items[ItemCount];
            if (SD^.LineType = 'PLU') and (SD^.SaleType = 'Sale') and (not SD^.LineVoided) and (SD^.Number = fieldbyname('ITEMNO').AsCurrency) and (GetModifierName(SD^.PLUModifierGroup, SD^.PLUModifier) = fieldbyname('MODIFIERNAME').AsString) then
            begin
              if SD^.FoodStampable then
              begin
                SaveExtPrice := SD^.ExtPrice;
                if LocalFSTotal > 0 then
                begin
                  if LocalFSTotal - SD^.SavDiscAmount < SD^.ExtPrice then
                  begin
{                    SD^.SavDiscAmount := SD^.SavDiscAmount + (LocalFSTotal * -1);
                    SD^.SavDiscable := SaveExtPrice;
}
                     SD^.ExtPrice := SaveExtPrice + (LocalFSTotal * -1);
                     LocalFSTotal := 0;
                     if SD^.SavDiscable = 0 then
                       SD^.SavDiscable := StrtoCurr(PromoNo);
                     SD^.Discable := True;
                  end
                  else
                  begin
{                    SD^.SavDiscAmount := SaveExtPrice * -1;
                    SD^.SavDiscable := SaveExtPrice;
}
                    SD^.ExtPrice := 0;
                    LocalFSTotal := LocalFSTotal - SaveExtPrice;
                    if SD^.SavDiscable = 0 then
                      SD^.SavDiscable := StrtoCurr(PromoNo);
                    SD^.Discable := True;
                  end;
                end;
              end
              else
              begin
                SaveExtPrice := SD^.ExtPrice;
                if LocalNFSTotal > 0 then
                begin
                  if LocalNFSTotal - SD^.SavDiscAmount < SD^.ExtPrice then
                  begin
{                    SD^.SavDiscAmount := SD^.SavDiscAmount + (LocalNFSTotal * -1);
                    SD^.SavDiscable := SaveExtPrice;
}
                     SD^.ExtPrice := SaveExtPrice + (LocalNFSTotal * -1);
                     LocalNFSTotal := 0;
                     if SD^.SavDiscable = 0 then
                       SD^.SavDiscable := StrtoCurr(PromoNo);
                     SD^.Discable := True;
                  end
                  else
                  begin
{                    SD^.SavDiscAmount := SaveExtPrice * -1;
                    SD^.SavDiscable := SaveExtPrice;
}
                     SD^.ExtPrice := 0;
                     LocalNFSTotal := LocalNFSTotal - SaveExtPrice;
                     if SD^.SavDiscable = 0 then
                       SD^.SavDiscable := StrtoCurr(PromoNo);
                     SD^.Discable := True;
                  end;
                end;
              end;
              sDiscName := CurrtoStr(SD^.Number);
              DisRecType := 'D';
              DisName := sDiscName;
              nDiscNo := StrtoInt(PromoNo);
              sLineType := 'DSC';
              sSaleType := 'Info';
              nDiscAmount := SD^.ExtPrice;
              nAmount := (SaveExtPrice - SD^.ExtPrice) * -1;
              nQty := PromoMatches;
              AddSaleList;
            end;
          end;
          next;
        end;
        Close;
      end;
      if POSDataMod.IBTempTrans2.InTransaction then
        POSDataMod.IBTempTrans2.Commit;

    end;

    procedure ComputePDIDiscount(PromotionNo : string);
    var
      ItemCount : integer;
      SD : pSalesData;
//      MaxListNo : integer;
//      MaxMatchQty : integer;
      FirstFound : boolean;
//      ListCount : integer;
      CurrList : integer;
      SoldCount : integer;
      SoldQty : integer;
//      SoldAmount : currency;
//      ItemSold : integer;
      PromoMatches : currency;
      PromoListMatchQty : integer;
      PromoType : string;
      PromoAmount : currency;
      ListFSTotal : currency;
      ListNFSTotal : currency;

    begin
      if not POSDataMod.IBTempTrans1.InTransaction then
        POSDataMod.IBTempTrans1.StartTransaction;
      with POSDataMod.IBTempQry1 do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT PR.LISTNO, MATCHQTY, PROMOTYPE, PROMOVALUE, ITEMNO, MODIFIERNAME FROM PROMOTIONS PR ');
        SQL.Add('INNER JOIN PROMOLISTS PL ON PR.LISTNO = PL.LISTNO ');
        SQL.Add('WHERE PROMONO = :pPromoNo AND ( ');
        FirstFound := false;
        for ItemCount := 0 to CurSaleList.Count -1 do
        begin
          SD := CurSaleList.Items[ItemCount];
          if (SD^.LineType = 'PLU') and (SD^.SaleType = 'Sale') and (not SD^.LineVoided) then
            if not FirstFound then
            begin
              SQL.Add(' ((ITEMNO = ' + CurrtoStr(SD^.Number) + ') AND (MODIFIERNAME = ''' + GetModifierName(SD^.PLUModifierGroup, SD^.PLUModifier) + ''')) ' );
              FirstFound := true;
            end
            else
              SQL.Add(' OR ((ITEMNO = ' + CurrtoStr(SD^.Number) + ') AND (MODIFIERNAME = ''' + GetModifierName(SD^.PLUModifierGroup, SD^.PLUModifier) + ''')) ' )
        end;
        SQL.Add(') ');
        SQL.Add('ORDER BY PR.LISTNO, ITEMNO ');
        ParamByName('pPromoNo').AsCurrency := StrtoCurr(PromoNo);
        Open;
        //Find Maximum Matches for Promotion
//        ListCount := 0;
        CurrList := 0;
        PromoMatches := 0;
        SoldQty := 0;
        PromoListMatchQty := 0;
        while not EOF do
        begin
          if fieldbyname('ListNo').AsInteger <> CurrList then
          begin
            if SoldQty > 0  then
            begin
              nQty := SoldQty div PromoListMatchQty;
              if ((PromoMatches = 0.0) or ((PromoMatches > 0.0) and (nQty < PromoMatches))) then
                PromoMatches := nQty;
            end;
//            inc(ListCount);
            CurrList := fieldbyname('ListNo').AsInteger;
            PromoListMatchQty := fieldbyname('MatchQty').AsInteger;
            SoldQty := 0;
          end;
          for ItemCount := 0 to CurSaleList.Count -1 do
          begin
            SD := CurSaleList.Items[ItemCount];
            if ((SD^.Number = fieldbyName('ITEMNO').AsCurrency) and (GetModifierName(SD^.PLUModifierGroup, SD^.PLUModifier) = fieldbyName('MODIFIERNAME').AsString)) and (SD^.LineType = 'PLU') and (SD^.SaleType = 'Sale') and (not SD^.LineVoided) then
            begin
              SoldQty := SoldQty + trunc(SD^.Qty);
            end;
          end;
          Next;
        end;
        nQty := SoldQty div PromoListMatchQty;
        if (PromoMatches = 0) or ((PromoMatches > 0) and (nQty < PromoMatches)) then
        begin
           PromoMatches := nQty;
        end;

        CurrList := 0;
        ListFSTotal := 0;
        ListNFSTotal := 0;
        nAmount := 0;
        First;
        PromoAmount := 0.0;
        while not EOF do
        begin
          if CurrList <> fieldbyname('ListNo').AsInteger then
          begin
            if CurrList <> 0 then
            begin
              if PromoType = C_DISC_PERCENT then
              begin
                PromoAmount := POSRound((ListFSTotal + ListNFSTotal) * (PromoAmount / 100),2);
                nAmount := nAmount + PromoAmount * -1;
              end
              else
                if PromoType = C_DISC_AMOUNT then
                  nAmount := nAmount + PromoAmount * -1
                else
                begin
                  PromoAmount := abs(PromoAmount - ListFSTotal - ListNFSTotal);
                  nAmount := PromoAmount * -1;
                end;
              if PromoAmount > ListNFSTotal then
              begin
                ListFSTotal := (PromoAmount - ListNFSTotal);
              end
              else
              begin
                ListNFSTotal := PromoAmount;
                ListFSTotal := 0;
              end;
              RemovePDIDiscounts(PromotionNo, CurrList, ListNFSTotal, ListFSTotal,PromoMatches);
              ListNFSTotal := 0;
              ListFSTotal := 0;
            end;
            CurrList := fieldbyname('ListNo').AsInteger;
            PromoType := fieldbyname('PROMOTYPE').AsString;
            PromoListMatchQty := fieldbyname('MatchQty').AsInteger;
            SoldQty := 0;
            if PromoType = C_DISC_PERCENT then
              PromoAmount := fieldbyName('PROMOVALUE').AsCurrency
            else
              PromoAmount := fieldbyName('PROMOVALUE').AsCurrency * PromoMatches;
          end;
          for ItemCount := 0 to CurSaleList.Count -1 do
          begin
            SD := CurSaleList.Items[ItemCount];
            if ((SD^.Number = fieldbyName('ITEMNO').AsCurrency) and (GetModifierName(SD^.PLUModifierGroup, SD^.PLUModifier) = fieldbyName('MODIFIERNAME').AsString)) and (SD^.LineType = 'PLU') and (SD^.SaleType = 'Sale') and (not SD^.LineVoided) then
            begin
              for SoldCount := 1 to trunc(SD^.Qty) do
              begin
                if SoldQty < PromoListMatchQty * PromoMatches then
                begin
                  if SD^.FoodStampable then
                    ListFSTotal := ListFSTotal + SD^.Price
                  else
                    ListNFSTotal := ListNFSTotal + SD^.Price;
                  inc(SoldQty);
                end;
              end;
            end;
          end;
          Next;
        end;
        if PromoType = C_DISC_PERCENT then
        begin
          PromoAmount := POSRound((ListFSTotal + ListNFSTotal) * (PromoAmount / 100),2);
          nAmount := nAmount + PromoAmount * -1;
        end
        else
          if PromoType = C_DISC_AMOUNT then
            nAmount := nAmount + PromoAmount * -1
          else
          begin
            PromoAmount := abs(PromoAmount - ListFSTotal - ListNFSTotal);
            nAmount := nAmount + PromoAmount * -1;
          end;
        if PromoAmount > ListNFSTotal then
        begin
          ListFSTotal := (PromoAmount - ListNFSTotal);
        end
        else
        begin
          ListNFSTotal := PromoAmount;
          ListFSTotal := 0;
        end;
        RemovePDIDiscounts(PromotionNo, CurrList, ListNFSTotal, ListFSTotal,PromoMatches);
        nQty := 1;
        Close;
      end;
      if POSDataMod.IBTempTrans1.InTransaction then
        POSDataMod.IBTempTrans1.Commit;

    end;

  begin
{    sDiscName := PromoName;
    DisRecType := 'D';
    DisName := sDiscName;
    nDiscNo := StrtoInt(PromoNo);
    sLineType := 'DSC';
    sSaleType := 'Info';
}
    ComputePDIDiscount(PromoNo);
//    AddSaleList;
    {$IFDEF FUEL_PRICE_ROLLBACK}
    DisplaySaleList(False);
    {$ELSE}
    DisplaySaleList;
    {$ENDIF}
    PoleMdse;
    ComputeSaleTotal;
    ClearEntryField;
    CheckSaleList;
  end;

  procedure ClearPDIAdjustments;
  var
    ItemCount : integer;
    SD : pSalesData;
  begin
    ItemCount := 0;
    while ItemCount < CurSaleList.Count do
    begin
      SD := CurSaleList.Items[ItemCount];
      if ((SD^.LineType = 'DSC')) then
      begin
        CurSaleList.Delete(ItemCount);
      end
      else
      begin
        inc(ItemCount);
        SD^.SeqNumber := ItemCount;
        SD^.SavDiscable := 0;
        SD^.SavDiscAmount := 0;
        SD^.ExtPrice := SD^.Qty * SD^.Price;
        SD^.Discable := false;
      end;
    end;
    ItemCount := 0;
    while ItemCount < CurSaleList.Count do
    begin
      if (POSListBox.Items[ItemCount][1] = 'D') then
        POSListBox.Items.Delete(ItemCount)
      else
        inc(ItemCount);
    end;
  end;

begin
  ClearPDIAdjustments;
  CurrentDate := FormatDateTime('mm/dd/yyyy',Date);
  CurrentTime := FormatDateTime('hh:nn',Time);
  DayAbbr := UpperCase(FormatDateTime('ddd',Date));

  if not POSDataMod.IBPDITransaction.InTransaction then
    POSDataMod.IBPDITransaction.StartTransaction;
  with POSDataMod.IBPDIQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT * FROM PROMOTIONS WHERE EFFSTARTDATE < :pCurrentDate ');
    SQL.Add('AND EFFSTOPDATE >= :pCurrentDate and ' + DayAbbr + 'FLAG = 1 ');
    SQL.Add('and (((' + DayAbbr + 'STARTTIME < :pCurrentTime) and (' + DayAbbr + 'STOPTIME >= :pCurrentTime)) ');
    SQL.Add('or ((' + DayAbbr + 'STARTTIME = ''00:00'') and (' + DayAbbr + 'STOPTIME = ''00:00''))) ');
    SQL.Add('Order by PromoNo, ListNo');
    ParamByName('pCurrentDate').AsDateTime := StrtoDate(CurrentDate);
    ParamByName('pCurrentTime').AsString := CurrentTime;

    Open;
    PromoNoBeingChecked := '';
    PromoNameBeingChecked := '';
    PromoMatched := true;
    PromoListsMatched := false;
    while not EOF do
    begin       //For each promotion
      if fieldbyname('PROMONO').AsString <> PromoNoBeingChecked then
      begin     //New promotion
        if ((PromoMatched) and (PromoListsMatched)) then
        begin   //Previous promotion fulfilled
          //Apply promotional discount
          ApplyPDIDiscount(PromoNameBeingChecked,PromoNoBeingChecked);
        end;
        PromoMatched := true;
        PromoNoBeingChecked := fieldbyname('PROMONO').AsString;
        PromoNameBeingChecked := fieldbyname('PROMONAME').AsString;
        PromoListtoCheck := fieldbyname('LISTNO').AsInteger;
        PromoMatchQty := fieldbyname('MATCHQTY').AsInteger;
      end
      else      //Check next list for current promotion
      begin
        PromoListtoCheck := fieldbyname('LISTNO').AsInteger;
        PromoMatchQty := fieldbyname('MATCHQTY').AsInteger;
      end;
      //Check Sales list against current promotion list
      PromoListsMatched := PromotionListMatch(PromoListtoCheck,PromoMatchQty);
      if not PromoListsMatched then
        PromoMatched := false;
      Next;     //Move to next promotion/list, if any
    end;
    Close;
  end;
  if PromoMatched and PromoListsMatched then
  begin   //Previous promotion fulfilled
    //Apply promotional discount
    ApplyPDIDiscount(PromoNameBeingChecked,PromoNoBeingChecked);
  end;
  if POSDataMod.IBPDITransaction.InTransaction then
    POSDataMod.IBPDITransaction.Commit;

end;
{$ELSE}  // PDI_PROMOS
{-----------------------------------------------------------------------------
  Name:      TfmPOS.CheckForAdjustment
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.CheckForAdjustment(const CurSaleData : pSalesData);
var
  count,idx, StartQty, CurQty, BeginQty, EndQty : integer;
  DiscAmount, AdjPrice, AddtnlDiscAmount : currency;
  SD : pSalesData;
  //20070606a...
  cUnitDiscAmount : currency;
  iUnitDiscQty : integer;
  qSalesData : pSalesData;
  bMatchingMixMatch : boolean;
  j : integer;
  j2 : integer;
  //...20070606a
  QtyToMarkUsed : integer;
  bResetVendorDiscounts : boolean;
  n : TDateTime;
  origtaxno : integer;
begin
  n := Now();
  UpdateZLog('TfmPOS.CheckForAdjustment - Enter');
  bResetVendorDiscounts := False;
  if CurSaleData^.SplitQty <= 0  then
  begin
    if not POSDataMod.IBMixMatchTransaction.InTransaction then
      POSDataMod.IBMixMatchTransaction.StartTransaction;
    with PosDataMod.IBMixMatchQuery do
    begin
      //20070606a...
      Close();
      SQL.Clear();
      SQL.Add('Select * from MixMatch where MMType1 > 0 order by Qty desc');
      //...20070606a
      Open;
      if RecordCount > 0 then
      begin
         First;
         while not Eof do
         begin
           GetMixMatch(PosDataMod.IBMixMatchQuery, @Mix);

           if not (between(n, Mix.StartDate, Mix.ExpirationDate) and
                   between(n, Mix.StartTime, Mix.EndTime)) then
           begin
             // Mix match has expired or hasn't started, so just skip it
           end
           else
           if Mix.RecType = MM_SPLIT then
           begin
             case Mix.MMType1 of
             MM_VENDOR :
               begin
                 if Mix.MMNo1 = CurSaleData^.VendorNo then
                 begin
                   //20070606a...
//                   DiscAmount := MMSplitAdjust;
                   DiscAmount := MMSplitAdjust(CurSaleData, cUnitDiscAmount, iUnitDiscQty, bResetVendorDiscounts);
                   //...20070606a
                   origtaxno := CurSaleData^.TaxNo;
                   if DiscAmount <> 0 then
                   begin
                     sDiscName := Mix.Name;
                     //20070606a...
//                     AutoDisc('MXM', MixMMNo, DiscAmount);
                     AutoDisc(CurSaleData, 'MXM', Mix.MMNo, cUnitDiscAmount, iUnitDiscQty, origtaxno);
                     //...20070606a
                     break;
                   end;
                 end;
               end;
             MM_DEPT  :
               begin
                 if Mix.MMNo1 = CurSaleData^.DeptNo then
                 begin
                   //20070606a...
//                   DiscAmount := MMSplitAdjust;
                   DiscAmount := MMSplitAdjust(CurSaleData, cUnitDiscAmount, iUnitDiscQty);
                   //...20070606a
                   origtaxno := CurSaleData^.TaxNo;
                   {$IFDEF DEBUG} UpdateZLog('MMSplitAdjust(%s, %.2g, %d) returned %.2g', [cursaledata.Name, cunitdiscamount, iunitdiscqty, discamount]); {$ENDIF}
                   if DiscAmount > 0 then
                   begin
                     sDiscName := Mix.Name;
                     //20070606a...
//                     AutoDisc('MXM', MixMMNo, DiscAmount);
                     AutoDisc(CurSaleData, 'MXM', Mix.MMNo, cUnitDiscAmount, iUnitDiscQty, origtaxno);
                     //...20070606a
                     break;
                   end;
                 end;
               end;
             MM_PLU :
               begin
                 if Mix.MMNo1 = CurSaleData^.Number then
                 begin
                   //20070606a...
//                   DiscAmount := MMSplitAdjust;
                   DiscAmount := MMSplitAdjust(CurSaleData, cUnitDiscAmount, iUnitDiscQty);
                   //...20070606a
                   origtaxno := CurSaleData^.TaxNo;
                   if DiscAmount <> 0 then    //20070724a (changed greater than to not equal)
                   begin
                     //20070606a...
                     // Remove any prior PLU mix match discounts that apply to this item or vendor.
                     QtyToMarkUsed := Abs(iUnitDiscQty * Mix.Qty);
                     bResetVendorDiscounts := True;
                     idx := 0;
                     Count := CurSaleList.Count;
                     for j := 0 to Count - 1 do
                     begin
                       if (idx > CurSaleList.Count - 1) then  // In case count changes
                         break;
                       qSalesData := CurSaleList.Items[idx];
                       if (qSalesData^.LineVoided) then
                       begin
                         // skip entries already voided from sales list
                       end
                       else if ((qSalesData^.LineType = 'PLU') and (qSalesData^.Number = CurSaleData^.Number)
                                and (Abs(qSalesData^.Qty) > Abs(qSalesData^.QtyUsedForSplitOrMM)) and (QtyToMarkUsed > 0)) then
                       begin
                         // Mark quantity as being used for this discount.
                         j2 := min(Round(Abs(qSalesData^.Qty) - Abs(qSalesData^.QtyUsedForSplitOrMM)), QtyToMarkUsed);
                         Dec(QtyToMarkUsed, j2);
                         Inc(qSalesData^.QtyUsedForSplitOrMM, j2 * Sign(iUnitDiscQty));
                       end
                       else if ((qSalesData^.LineType = 'DSC') or (qSalesData^.LineType = 'MXM')) then
                       begin
                         // This item is a discount.  See if it matches this PLU.
                         try
                           if not POSDataMod.IBTransaction.InTransaction then
                             POSDataMod.IBTransaction.StartTransaction;
                           with POSDataMod.IBTempQuery do
                           begin
                             Close;SQL.Clear;
                             SQL.Add('SELECT * FROM MixMatch Where (MMNo = :pMMNo and MMNo1 = :pMMNo1 and MMType1 = :pMMType1 and Qty < :pQty)');
                             SQL.Add(' or (MMNo1 > 0 and MMNo1 = :pMMNo1Vendor and MMType1 = :pMMType1Vendor)');
                             SQL.Add(' or (MMNo1 > 0 and MMNo1 = :pMMNo1ProdGrp and MMType1 = :pMMType1ProdGrp)');
                             ParamByName('pMMType1Vendor').AsInteger := MM_VENDOR;
                             ParamByName('pMMNo1Vendor').AsInteger := qSalesData^.VendorNo;
                             ParamByName('pMMType1ProdGrp').AsInteger := MM_PRODGRP;
                             ParamByName('pMMNo1ProdGrp').AsInteger := qSalesData^.ProdGrpNo;
                             ParamByName('pMMNo').AsInteger := Round(qSalesData^.Number);
                             ParamByName('pMMNo1').AsCurrency := Mix.MMNo1;
                             ParamByName('pMMType1').AsInteger := MM_PLU;
                             ParamByName('pQty').AsInteger := Mix.QTY;
                             Open;
                             bMatchingMixMatch := (not EOF);
                             Close;
                           end;
                           if POSDataMod.IBTransaction.InTransaction then
                             POSDataMod.IBTransaction.Commit;
                         except
                           bMatchingMixMatch := False;
                           if POSDataMod.IBTransaction.InTransaction then
                             POSDataMod.IBTransaction.Rollback;
                         end;

                         if (bMatchingMixMatch) then
                         begin
                           // Remove the discount.
                           CurSaleList.Remove(qSalesData);
                           Dispose(qSalesData);
                           CurSaleList.Pack();
                           for j2 := idx to CurSaleList.Count - 1 do
                           begin
                             qSalesData := CurSaleList.Items[j2];
                             Dec(qSalesData^.SeqNumber);
                           end;
                           POSListBox.Items.Delete(idx);
                           // Following will cancel with increment at end of loop to cause
                           // the new item that now occupies this index to be processed.
                           Dec(idx);
                         end;
                       end;  // if ((qSalesData^.LineType = 'DSC') ...
                       Inc(idx);  // Next item (for loop index not used because items are re-indexed within loop)
                     end;  // for j := 0 to Count -1
                     //...20070606a
                     sDiscName := Mix.Name;
                     //20070606a...
//                     AutoDisc('MXM', MixMMNo, DiscAmount);
//                     break;
                     AutoDisc(CurSaleData, 'MXM', Mix.MMNo, cUnitDiscAmount, iUnitDiscQty, origtaxno);
                     //...20070606a
                   end;
                 end;
               end;
             MM_PRODGRP :
               begin
                 if Mix.MMNo1 = CurSaleData^.ProdGrpNo then
                 begin
                   //20070606a...
//                   DiscAmount := MMSplitAdjust;
                   DiscAmount := MMSplitAdjust(CurSaleData, cUnitDiscAmount, iUnitDiscQty, bResetVendorDiscounts);
                   //...20070606a
                   origtaxno := CurSaleData^.TaxNo;
                   if DiscAmount > 0 then
                   begin
                     sDiscName := Mix.Name;
                     //20070606a...
//                     AutoDisc('MXM', MixMMNo, DiscAmount);
                     AutoDisc(CurSaleData, 'MXM', Mix.MMNo, cUnitDiscAmount, iUnitDiscQty, origtaxno);
                     //...20070606a
                     break;
                   end;
                 end;
               end;
             MM_MODIFIER :
               begin
                 if (Mix.MMNo1 = CurSaleData^.PLUModifier) and
                   (Mix.MMNo1a = CurSaleData^.PLUModifierGroup) then
                 begin
                   //20070606a...
//                   DiscAmount := MMSplitAdjust;
                   DiscAmount := MMSplitAdjust(CurSaleData, cUnitDiscAmount, iUnitDiscQty);
                   //...20070606a
                   if DiscAmount > 0 then
                   begin
                     sDiscName := Mix.Name;
                     //20070606a...
//                     AutoDisc('MXM', MixMMNo, DiscAmount);
                     AutoDisc(CurSaleData, 'MXM', Mix.MMNo, cUnitDiscAmount, iUnitDiscQty);
                     //...20070606a
                     break;
                   end;
                 end;
               end;
             end;
           end
           else
           if Mix.RecType = MM_COMBO then
           begin
             DiscAmount := 0;
             for count := 1 to Trunc(CurSaleData^.Qty) do
             begin
               AddtnlDiscAmount := 0;
               case Mix.MMType1 of
               MM_VENDOR :
                 begin
                   if Mix.MMNo1 = CurSaleData^.VendorNo then
                   begin
                     AddtnlDiscAmount := MMComboAdjust(CurSaleData, Mix.MMType2, Mix.MMNo2a, Mix.MMNo2);
                   end;
                 end;
               MM_DEPT  :
                 begin
                   if Mix.MMNo1 = CurSaleData^.DeptNo then
                   begin
                     AddtnlDiscAmount := MMComboAdjust(CurSaleData, Mix.MMType2, Mix.MMNo2a, Mix.MMNo2);
                   end;
                 end;
               MM_PLU :
                 begin
                   if Mix.MMNo1 = CurSaleData^.Number then
                   begin
                     AddtnlDiscAmount := MMComboAdjust(CurSaleData, Mix.MMType2, Mix.MMNo2a, Mix.MMNo2);
                   end;
                 end;
               MM_PRODGRP :
                 begin
                   if (Mix.MMNo1 = CurSaleData^.ProdGrpNo) then
                   begin
                     AddtnlDiscAmount := MMComboAdjust(CurSaleData, Mix.MMType2, Mix.MMNo2a, Mix.MMNo2);
                   end;
                 end;
               MM_MODIFIER :
                 begin
                   if (Mix.MMNo1 = CurSaleData^.PLUModifier) and
                     (Mix.MMNo1a = CurSaleData^.PLUModifierGroup) then
                   begin
                     AddtnlDiscAmount := MMComboAdjust(CurSaleData, Mix.MMType2, Mix.MMNo2a,  Mix.MMNo2);
                   end;
                 end;
               end; //end case MMType1

               if AddtnlDiscAmount > 0 then
               begin
                 DiscAmount := DiscAmount + AddtnlDiscAmount;
                 continue;
               end;
               case Mix.MMType2 of
               MM_VENDOR :
                 begin
                   if Mix.MMNo2 = CurSaleData^.VendorNo then
                   begin
                     DiscAmount := DiscAMount + MMComboAdjust(CurSaleData, Mix.MMType1, Mix.MMNo1a,  Mix.MMNo1);
                     continue;
                   end;
                 end;
               MM_DEPT  :
                 begin
                   if Mix.MMNo2 = CurSaleData^.DeptNo then
                   begin
                     DiscAmount := DiscAMount + MMComboAdjust(CurSaleData, Mix.MMType1, Mix.MMNo1a, Mix.MMNo1);
                     continue;
                   end;
                 end;
               MM_PLU :
                 begin
                   if Mix.MMNo2 = CurSaleData^.Number then
                   begin
                     DiscAmount := DiscAMount + MMComboAdjust(CurSaleData, Mix.MMType1, Mix.MMNo1a, Mix.MMNo1);
                     continue;
                   end;
                 end;
               MM_PRODGRP :
                 begin
                   if (Mix.MMNo2 = CurSaleData^.ProdGrpNo) then
                   begin
                     DiscAmount := DiscAMount + MMComboAdjust(CurSaleData, Mix.MMType1, Mix.MMNo1a, Mix.MMNo1);
                     continue;
                   end;
                 end;
               MM_MODIFIER :
                 begin
                   if (Mix.MMNo2 = CurSaleData^.PLUModifier) and
                     (Mix.MMNo2a = CurSaleData^.PLUModifierGroup) then
                   begin
                     DiscAmount := DiscAMount + MMComboAdjust(CurSaleData, Mix.MMType1, Mix.MMNo1a, Mix.MMNo1);
                     continue;
                   end;
                 end;
               end; //end case MMType1
             end;  //end for loop
             if DiscAmount > 0 then
             begin
               sDiscName := Mix.Name;
               //20070606a...
//               AutoDisc('MXM', MixMMNo, DiscAmount);
               AutoDisc(CurSaleData, 'MXM', Mix.MMNo, DiscAmount, 1);
               //...20070606a
               break;
             end;
           end;
           Next;
         end;
      end;
      close;
    end;
    if POSDataMod.IBMixMatchTransaction.InTransaction then
      POSDataMod.IBMixMatchTransaction.Commit;
  end
  else
  if CurSaleData^.SplitQty > 0  then
    begin
      AdjPrice := CurSaleData^.Price - (CurSaleData^.SplitPrice - (( CurSaleData^.SplitQty - 1 ) * CurSaleData^.Price ));
      BeginQty := 0;

      if CurSaleList.Count > 1 then
        begin
          for idx := 0 to CurSaleList.Count - 2 do
            begin
              SD := CurSaleList.Items[idx];
              if (SD^.LineType = CurSaleData^.LineType) and (SD^.Number = CurSaleData^.Number) and (SD^.LineVoided = False) and (SD^.SaleType = 'Sale') then
                BeginQty := BeginQty + Trunc(SD^.Qty);
            end;
        end;
      if BeginQty > 0 then
        StartQty := BeginQty mod CurSaleData^.SplitQty
      else
        StartQty := 0;
      EndQty := StartQty + Trunc(CurSaleData^.Qty);
      Inc(StartQty);
      DiscAmount := 0;
      for CurQty := StartQty to EndQty do
        begin
          if (CurQty mod CurSaleData^.SplitQty) = 0 then
            DiscAmount := DiscAmount + AdjPrice;
        end;
      if DiscAmount > 0 then
        begin
          sDiscName := 'Sale ' + IntToStr(CurSaleData^.SplitQty) + ' for ' + CurrToStr(CurSaleData^.SplitPrice);
          //20070606a...
//          AutoDisc('DSC', Setup.SplitDisc, DiscAmount);
          AutoDisc(CurSaleData, 'DSC', Setup.SplitDisc, DiscAmount, 1);
          //...20070606a
        end;
    end;
  UpdateZLog('TfmPOS.CheckForAdjustment - Exit');
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.MMComboAdjust
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: MMTypeName, MMNoNameA : Integer; MMNoName : double
  Result:    currency
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.MMComboAdjust(const CurSaleData : pSalesData; MMTypeName, MMNoNameA : Integer; MMNoName : double) : currency;
var
  idx  : integer;
  DiscAmount : currency;
  SD : pSalesData;
  FoundComboItem : boolean;
  MinSalesListCount : integer;
begin
  if ((CurSaleData^.Qty - 1 > CurSaleData^.QtyUsedForSplitOrMM) and (Mix.Price < 0.0)) then
    MinSalesListCount := 1
  else
    MinSalesListCount := 2;
  FoundComboItem := False;
  SD := nil;
  if CurSaleList.Count >= MinSalesListCount then
  begin
    for idx := 0 to CurSaleList.Count - MinSalesListCount do
    begin
      SD := CurSaleList.Items[idx];
      if ((SD^.LineType = 'PLU') or (SD^.LineType = 'DPT')) and (SD^.LineVoided = False) and (SD^.SaleType = 'Sale') and ((SD^.Qty - SD^.QtyUsedForSplitOrMM) > 0 )then
      begin
        case MMTypeName of
        MM_VENDOR :
          begin
            if MMNoName = SD^.VendorNo then
            begin
              FoundComboItem := True;
            end;
          end;
        MM_DEPT  :
          begin
            if MMNoName = SD^.DeptNo then
            begin
              FoundComboItem := True;
            end;
          end;
        MM_PLU :
          begin
            if MMNoName = SD^.Number then
            begin
              FoundComboItem := True;
            end;
          end;
        MM_PRODGRP :
          begin
            if MMNoName = SD^.ProdGrpNo then
            begin
              FoundComboItem := True;
            end;
          end;
        MM_MODIFIER :
          begin
            if (MMNoName = SD^.PLUModifier) and
              (MMNoNameA = SD^.PLUModifierGroup) then
            begin
              FoundComboItem := True;
            end;
          end;
        end;   // end case
      end;

      if FoundComboItem then break;
    end;   // end for
  end;     //end if

  DiscAmount := 0;
  if FoundComboItem then
  begin
    if (Mix.Price >= 0) then
    begin
      DiscAmount := (CurSaleData^.Price + SD^.Price) - (Mix.Price) ;
      Inc(CurSaleData^.QtyUsedForSplitOrMM);
    end
    else
    begin
      DiscAmount := - Mix.Price;
    end;
    Inc(SD^.QtyUsedForSplitOrMM);
  end;
  MMComboAdjust := DiscAmount;

end;  // end combo adjust

function TfmPOS.LastSaleItem( sl : TNotList ) : integer;
var
  i : integer;
  lt : string;
begin
  i := -1;
  if sl.Count <> 0 then
    while i < sl.Count do
    begin
      inc( i );
      if i < sl.Count then
      begin
        lt := pSalesData( sl.Items[ i ] ).LineType;
        if (lt = 'TAX') or (lt = 'MED') then break;
      end;
    end;
  Result := i;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.MMSplitAdjust
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    currency
  Purpose:
-----------------------------------------------------------------------------}
//20070606a...
//function TfmPOS.MMSplitAdjust : currency;
function TfmPOS.MMSplitAdjust(const CurSaleData : pSalesData; var cUnitDiscountAmount : currency; var iUnitDiscountQuantity : integer; const bReset : boolean = False) : currency;
{
Determine the quantity of discount that applies to the sales list.
If bReset is False (normal case), then assume that all but the last item has already had a
discount applied to the sales list (so only consider any remaining qualifying item quantity)
If bReset is True, then all sales list items are are used to calculate qualifying item quanity.
}
//...20070606a
var
  idx, StartQty, CurQty, BeginQty, EndQty : integer;
  DiscAmount, AdjPrice : currency;
  SD : pSalesData;
  idxEnd : integer;  //20070606a
  QtyToUse : integer;
begin
  BeginQty := 0;
  //20070606a...
//  if CurSaleList.Count > 1 then
//  begin
//    for idx := 0 to CurSaleList.Count - 2 do
  if (Mix.MMType1 = MM_PLU) then idxEnd := LastSaleItem( CurSaleList ) - 1
  else                           idxEnd := LastSaleItem( CurSaleList ) - 2;
  if (idxEnd >= 0) then
  begin
    for idx := 0 to idxEnd do
  //...20070606a
    begin
      SD := CurSaleList.Items[idx];
      if (bReset or (Mix.Qty = 1)) then
        QtyToUse := Trunc(SD^.Qty - SD^.QtyUsedForSplitOrMM)
      else
        QtyToUse := Trunc(SD^.Qty);
      // If item has any remaining quantity that was not previously applied to a discount
      if (QtyToUse <> 0) and
          (SD^.LineType = 'PLU') and (SD^.LineVoided = False) and ((SD^.Saletype = 'Sale')
                                                                  or (SD^.Saletype = 'Rtrn')) then  //20070724a
      //...20101027a
      begin
        case Mix.MMType1 of
        MM_VENDOR :
          begin
            if Mix.MMNo1 = SD^.VendorNo then
            begin
              BeginQty := BeginQty + QtyToUse;
            end;
          end;
        MM_DEPT  :
          begin
            if Mix.MMNo1 = SD^.DeptNo then
            begin
              BeginQty := BeginQty + QtyToUse;
            end;
          end;
        MM_PLU :
          begin
            if Mix.MMNo1 = SD^.Number then
            begin
              BeginQty := BeginQty + QtyToUse;
            end;
          end;
        MM_PRODGRP :
          begin
            if Mix.MMNo1 = SD^.ProdGrpNo then
            begin
              BeginQty := BeginQty + QtyToUse;
            end;
          end;
        MM_MODIFIER :
          begin
            if (Mix.MMNo1 = SD^.PLUModifier) and
              (Mix.MMNo1a = SD^.PLUModifierGroup) then
            begin
              BeginQty := BeginQty + QtyToUse;
            end;
          end;
        end;   // end case
      end  // end if (SD^.LineType = 'PLU' ...
      //20070606a...
      else if (SD^.LineType = 'DSC') and (SD^.LineVoided = False) then
      begin
        case Mix.MMType1 of
        MM_PLU :
          begin
            // See if this discount is for a higher quantity.  If so, then do not count
            // the quantity needed to satisfy the discount.
            try
              if not POSDataMod.IBTransaction.InTransaction then
                POSDataMod.IBTransaction.StartTransaction;
              with POSDataMod.IBTempQuery do
              begin
                Close;SQL.Clear;
                SQL.Add('SELECT * FROM MixMatch Where MMNo = :pMMNo and MMNo1 = :pMMNo1 and MMType1 = :pMMType1 and Qty >= :pQty');
                ParamByName('pMMNo').AsInteger := Round(SD^.Number);
                ParamByName('pMMNo1').AsCurrency := Mix.MMNo1;
                ParamByName('pMMType1').AsInteger := Mix.MMType1;
                ParamByName('pQty').AsInteger := Mix.QTY;
                Open;
                if (not EOF) then
                  BeginQty := BeginQty - (QtyToUse * FieldByName('Qty').AsInteger);
                Close;
              end;
              if POSDataMod.IBTransaction.InTransaction then
                POSDataMod.IBTransaction.Commit;
            except
              if POSDataMod.IBTransaction.InTransaction then
                POSDataMod.IBTransaction.Rollback;
            end;
          end;
        end;   // end case
      end;   // end if (SD^.LineType = 'DSC' ...
      //...20070606a
    end;   // end for idx := 0 to CurSaleList.Count - 2
  end;     //end if CurSaleList.Count > 0


  //20070606a...
  if (Mix.MMType1 = MM_PLU) then
  begin
    cUnitDiscountAmount := Mix.Qty * CurSaleData^.Price - Mix.Price;
    iUnitDiscountQuantity := BeginQty div Mix.Qty;
    MMSplitAdjust := iUnitDiscountQuantity * cUnitDiscountAmount;
  end
  else
  //...20070606a
  begin
    // For negative price values in MixMatch DB table, use absolulte value as the discounted amount;
    // otherwise, use the difference in purchasing MixQty quantity of the item and the MixMatch price.
    if (Mix.Price < 0) then
      AdjPrice := -Mix.Price
    else
      AdjPrice := CurSaleData^.Price - (Mix.Price - (( Mix.Qty - 1 ) * CurSaleData^.Price ));

    QtyToUse := Trunc(CurSaleData^.Qty);
    if ((Mix.Qty = 1) or (bReset and (Mix.Qty > 0))) then
    begin
      // Allow discount for all quantity after (but not including) the first qualifying item purchased.
      if (bReset and (Abs(BeginQty) > 1)) then
        iUnitDiscountQuantity := BeginQty div Mix.Qty
      else if (bReset) then
        iUnitDiscountQuantity := 0
      else if (Abs(BeginQty) = 1) then
        iUnitDiscountQuantity := (BeginQty + QtyToUse) div Mix.Qty
      else if (Abs(BeginQty + QtyToUse) > 1) then
        iUnitDiscountQuantity := QtyToUse div Mix.Qty
      else
        iUnitDiscountQuantity := 0;
      DiscAmount := iUnitDiscountQuantity * AdjPrice;
    end
    else
    begin
      if Abs(BeginQty) > 0 then
        StartQty := BeginQty mod Mix.Qty
      else
        StartQty := 0;

      EndQty := StartQty + QtyToUse;
      Inc(StartQty);
      DiscAmount := 0;
      iUnitDiscountQuantity := 0;
      for CurQty := StartQty to EndQty do
        begin
          if (CurQty mod Mix.Qty) = 0 then
          begin
            DiscAmount := DiscAmount + AdjPrice;
            Inc(iUnitDiscountQuantity);
          end;
        end;
    end;

    cUnitDiscountAmount := AdjPrice;
    MMSplitAdjust := DiscAmount;
  end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.AutoDisc
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: DiscType : string; DiscNo : integer; DiscAmount : currency
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
//20070606a...
//procedure TfmPOS.AutoDisc(DiscType : string; DiscNo : integer; DiscAmount : currency);
function TfmPOS.AutoDisc(const item: pSalesData; const DiscType : string; const DiscNo : integer; const UnitDiscAmount : currency; const DiscountQty : integer; taxno : integer=0) : pSalesData;
//...20070606a
var
  CurSaleData : pSalesData;
begin
  UpdateZLog('AutoDisc - DiscType: %s  DiscNo: %d  UnitDiscAmt: %.3g  DiscQty: %d  MR: %x  TaxNo: %d', [disctype, discno, unitdiscamount, discountqty, item.mediarestrictioncode, taxno]);
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBDiscQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Select * from Disc where DiscNo = :pDiscNo');
    ParamByName('pDiscNo').AsInteger := DiscNo;
    Open;
    if EOF then
    begin
      Close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      POSError('Discount For Split Not Defined');
      AutoDisc := nil;
      Exit;
    end
    else
    begin
      DisDISCNO := fieldbyname('DiscNo').Asinteger;
      DisNAME := fieldbyname('Name').Asstring;
      DisREDUCETAX := fieldbyname('ReduceTax').Asinteger;
      DisAMOUNT := fieldbyname('Amount').Ascurrency;
      DisRECTYPE := fieldbyname('RecType').AsString;
    end;
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  nDiscNo := DisDiscNo;
  //20070606a...
//  nDiscAmount := DiscAmount;
  nDiscAmount := UnitDiscAmount;
  //...20070606a
  nAmount := nDiscAmount * -1;
  nAmount := POSRound(nAmount,2);
  //20070606a...
//  nQty := 1;
  nQty := DiscountQty;
  //...20070606a
  sLineType := 'DSC';
  sSaleType := 'Sale';
  CurSaleData := AddSaleList;
  if DisReduceTax = 1 then
  begin
    CurSaleData.TaxNo := taxno;
    CurSaleData.Taxable := nAmount;
  end;
  CurSaleData^.VendorNo := item^.VendorNo;
  CurSaleData^.ProdGrpNo := item^.ProdGrpNo;
  CurSaleData^.FoodStampable := item^.FoodStampable;
  CurSaleData^.mediarestrictioncode := item^.mediarestrictioncode;
  CurSaleData.QtyUsedForSplitOrMM := DiscountQty;
  PoleMdse(CurSaleData, SaleState);
  ComputeSaleTotal;
  ClearEntryField;
  AutoDisc := CurSaleData;

end;
{$ENDIF}  // else clause of PDI_PROMOS


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisplaySaleList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.DisplaySaleList(const CurSaleData : pSalesData; const bDisplayAtCurrentPosition : boolean = False);

var
  s: string;
  InsertIndex : integer;
  j : integer;
begin
  //XMD
  //if CurSaleData^.LineType = 'FUL' then
  if (CurSaleData^.LineType = 'FUL') or (CurSaleData^.LineType = 'XMD') then
  //XMD
  begin
    s :=  Format('%-20s',[CurSaleData^.Name])  + ' ' +
          Format('%6s',[(FormatFloat('###.##',CurSaleData^.Qty))]) +
          Format('%7s',[(FormatFloat('###.00 ;###.00-',CurSaleData^.ExtPrice))]);
  end
  else if (CurSaleData^.LineType = SALE_DATA_LINE_TYPE_MESSAGE) then
  begin
    s := CurSaleData^.Name;
  end
  else
  {$IFDEF MULTI_TAX}
  if (CurSaleData^.LineType <> 'TAX') then
  {$ENDIF}
  begin
    s :=  Format('%-20s',[copy(CurSaleData^.Name,1,20)])  + ' ' +
          Format('%3s',[(FormatFloat('###',CurSaleData^.Qty))])  + ' ' +
          Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',CurSaleData^.ExtPrice))]);
  {$IFDEF MULTI_TAX}
  end
  else
  begin
    s := '';
  {$ENDIF}
  end;

  //20060907d  (correct next statement so that an item with only one tax will be marked)
  if (ItemTaxed(CurSaleData)) then
    s := s + 'T'
  else
    s := s + ' ';

  if CurSaleData^.Discable then
    s := s + 'D'
  else
    s := s + ' ';
  if bitset(CurSaleData^.mediarestrictioncode, MRC_bSNAP) then
    s := s + 'F'
  else
    s := s + ' ';

  if (CurSaleData^.LineVoided = True) or (CurSaleData^.SaleType = 'Void') then
    s := 'R' + s
  //DSG
  //else if CurSaleData^.LineType = 'DSC' then
  else if (CurSaleData^.LineType = 'DSC') or
          {$IFDEF CASH_FUEL_DISC}
          (CurSaleData^.LineType = 'DS$') or
          {$ENDIF}
          {$IFDEF ODOT_VMT}
          (CurSaleData^.LineType = 'DSV') or
          {$ENDIF}
          {$IFDEF FF_PROMO}
          (CurSaleData^.LineType = 'FFP') or
          {$ENDIF}
          (CurSaleData^.LineType = 'DSG') then
  //DSG
    s := 'D' + s
  else if CurSaleData^.LineType = 'MXM' then
    s := 'D' + s
  else if (CurSaleData^.LineType = SALE_DATA_LINE_TYPE_MESSAGE) then
    s := 'D' + s
  else
    s := 'B' + s;

  {$IFDEF FALSE}  // had been IFDEF MULTI_TAX
  if (CurSaleData^.LineType <> 'TAX') and (CurSaleData.LineType<>'MED')
//      {$IFDEF PDI_PROMOS}  //20070305b (moved below)
      //Prevent double display of Void lines in the Display List
      and (CurSaleData.SaleType <> 'Void')
      {$IFDEF PDI_PROMOS}  //20070305b (moved from above)
      and not ((CurSaleData.LineType='DSC') and (CurSaleData.SaleType='Info'))
      {$ENDIF}
                                                   then
  {$ENDIF}
  begin
    // This is SUPER hacky, but!  LockCount is "normally" -1
    // When we're throwing things back into the listbox from a resume
    // it equals -2 because CSSuspendList is entered in RecallSale
    if (POSListBox.Items.Count = 0) or (CSSuspendList.LockCount < -1) then
      POSListBox.Add(s)
    else
    begin
      if bDisplayAtCurrentPosition then
      begin
        InsertIndex := POSListBox.ItemIndex;
      end
      else
      begin
        if bUseFoodStamps then
          InsertIndex := POSListBox.Items.Count - 4
        else
          InsertIndex := POSListBox.Items.Count - 3;
        // Use above as a default index; however, there should be a blank
        // line after the last item, so just insert before that line.
        for j := POSListBox.Items.Count - 1 downto 0 do
        begin
          if (POSListBox.Items.Strings[j][1] = 'L') then
          begin
            InsertIndex := j;
            break;
          end;
        end;
      end;
      POSListBox.Insert(InsertIndex, s);
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ComputeSaleTotal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ComputeSaleTotal();
begin
  //Gift
  ReComputeSaleTotal(false);
  //ReComputeSaleTotal;
  //Gift
  DisplaySaleTotal;
  SetNextDollarKeyCaption;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisplaySaleTotal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.DisplaySaleTotal();
var
  sBlank, sSubLine, sTaxLine, sFSSubLine : string;
  i : integer;
  sBlankPos : integer;
  taxname : string;
begin
  if lTotal.Caption = 'Total' then
    eTotal.Text := Format('%12s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nTotal))])
  else if lTotal.Caption = 'Amount Due' then
    eTotal.Text := Format('%12s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nAmountDue))]);

  if bUseFoodStamps then
    sFSSubLine := Format('%22s',['FS Subtotal']) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nFSSubtotal))]);

  sSubLine := Format('%22s',['Subtotal']) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nSubtotal))]);
  if curSale.bSalesTaxXcpt then
    taxname := 'Sales Tax Exempt'
  else
    taxname := 'Tax';
  sTaxLine := Format('%22s',[taxname]) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nTlTax))]);

  // Find the subtotal line across the window
  sBlankPos := -1;
  for i := 0 to Pred( POSListBox.Items.Count ) do
    if PosListBox.Items[ i ][1] = 'L' then
    begin
      sBlankPos := i;
      break;
    end;

  // if we haven't found it, just stuff everything into place
  if sBlankPos = -1 then
    begin
      sBlank := StringOfChar(' ',40);
      sBlankPos := POSListBox.Add('L' + sBlank);
      if bUseFoodStamps then
        POSListBox.Add('B' + sFSSubLine);
      POSListBox.Add('B' + sSubLine);
      POSListBox.Add('B' + sTaxLine);
    end
  else
    // if we have, base our updates on the subtotal line
    begin
      i := sBlankPos + 1;
      if bUseFoodStamps then
      begin
        POSListBox.Items.Strings[i] := 'B' + sFSSubLine;
        inc(i);
      end;
      POSListBox.Items.Strings[i] := 'B' + sSubLine;
      inc(i);
      POSListBox.Items.Strings[i] := 'B' + sTaxLine;
    end;

  POSListBox.ItemIndex := sBlankPos - 1;

end;


procedure TfmPOS.RedisplaySalesItemsToPinPad();
var
  taxndx, i, t, lastitemidx: Integer;
  SD: pSalesData;
begin
   lastitemidx := -1;
  PPTrans.LastSeqNoDisplayed := 999;
  // Let pin pad class know about new sales item and totals (so it can update its display).
  UpdateZLog('VJ it should be displaying ' + IntToStr(CurSaleList.Count) + ' items');
  if (CurSaleList.Count > 0) then
  begin
    for i := 0 to Pred( CurSaleList.Count ) do
    begin
      SD := pSalesData( CurSaleList.Items[ i ] );
      if SD.LineType = 'TAX' then
      begin
        lastitemidx := i - 1;
        break;
      end;
      UpdateZLog('Item ' + IntToStr(i) + ' LineType = ' + SD.LineType);
      DisplaySaleDataToPinPad(PPTrans, SD);
    end;
    if lastitemidx > -1 then
      DisplaySaleDataToPinPad(PPTrans, CurSaleList.Items[ lastitemidx ]);
    nAmount := curSale.nAmountDue;
  end;
  
end;

procedure TfmPOS.PrintEMVDeclinedReceipt(VERIFIED_PIN : Boolean);
var
  ndx : integer;
  sd : pSalesData;
  CCMsg : string;
  idxFirstMediaLine : integer;
  Pass_VERIFIED_PIN : Boolean;
begin
    UpdateZLog('fmPOS.PrintEMVDeclinedReceipt() - enter');
    try
    EmptyReceiptList;

    // Move current sales data to the receipt list
    // (but move 'media' lines to the end).
    idxFirstMediaLine := 0;
    for ndx := 0 to (CurSaleList.Count - 1) do
    begin
      sd    := CurSaleList.Items[ndx];
      if (sd^.LineType = 'MED') then
      begin
        if (idxFirstMediaLine = 0) then
          idxFirstMediaLine := ndx;      // Save location of first media line (no need to search above this line for media)
      end
      else
      begin
        New(ReceiptData);
        ReceiptData^   := sd^;
        ReceiptData^.receipttext := sd^.receipttext;
        ReceiptList.Capacity := ReceiptList.Count;
        ReceiptList.Add(ReceiptData);
      end;
    end;
    for ndx := idxFirstMediaLine to (CurSaleList.Count - 1) do
    begin
      sd    := CurSaleList.Items[ndx];
      if (sd^.LineType = 'MED') then
      begin
        New(ReceiptData);
        ReceiptData^   := sd^;
        ReceiptData^.receipttext := sd^.receipttext;
        ReceiptList.Capacity := ReceiptList.Count;
        ReceiptList.Add(ReceiptData);
      end;
    end;
    Pass_VERIFIED_PIN := VERIFIED_PIN;
    if not Pass_VERIFIED_PIN then
    begin
       if OnlinePINVerified then Pass_VERIFIED_PIN := True;
    end;
    POSPrt.PrintEMVDecline(0, Pass_VERIFIED_PIN);
    except on E : Exception do
      begin
         UpdateZLog('Exception inside of PrintEMVDeclindedReceipt - ' + E.Message);
      end
    end;
    UpdateZLog('fmPOS.PrintEMVDeclinedReceipt() - exit');
end;
{-----------------------------------------------------------------------------
  Name:      TfmPOS.ReComputeSaleTotal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: bRestrictedOnly : boolean
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ReComputeSaleTotal(bRestrictedOnly : boolean);//Gift added bRestrictedOnly
var
  taxndx, i, t, lastitemidx: Integer;
  SD: pSalesData;
  ST: pSalesTax;
  FSST : pSalesTax;
  //Gift
  qTaxList   : pTList;
  qTotal     : ^Currency;
  qMedia     : ^Currency;
  qAmountDue : ^Currency;
  qSubTotal  : ^Currency;
  qTax       : ^Currency;
  qFoodStamp : ^Currency;
  FuelSubTotal : currency;
  nTOTUnused : currency;
  nMEDUnused : currency;
  nSTUnused  : currency;
  nTXUnused  : currency;
  nFSUnused  : currency;
  j, k : integer;
  q : pRestrictedDept;
  //20020204...
  PriorRestrictedMedia : currency;
  gd : pGiftCardData;
  //...20020204
  //20040802...
  qFSTaxList : pTList;
  //...20040802
  //Gift
  //20040827...
  MediaNumber : integer;
  //20040908...
//  TaxAdjustment : currency;
  NonAdjustedTax : currency;
  TaxableSalesToReduce : currency;
  TaxAmountToReduce : currency;
  TaxReduction : currency;
  TaxExempted : currency;
  QualifyingFSTax : currency;
  //...20040909
  //...20040827
begin
  UpdateZLog('RecomputeSaleTotal - enter - nCurAmountDue: %.2f', [curSale.nAmountDue]);
  // Determine pointers to accumlators
  q := nil;
  qFSTaxList := @(qClient^.RestrictSalesTaxList);  // Can use same list for food stamp as restricted, because these are never calculated with same call.
  if (bRestrictedOnly) then
  begin
    qAmountDue   := @(fmNBSCCForm.SinAmount);
    if (RestrictedDeptList.Count < 1) then
    begin
      qAmountDue^ := 0;     // Nothing is restricted.
      exit;  // Nothing left to do.
    end;
    qTotal     := @nTOTUnused;
    qTaxList   := @(qClient^.RestrictSalesTaxList);
    qMedia     := @nMEDUnused;
    qSubTotal  := @nSTUnused;
    qTax       := @nTXUnused;
    qFoodStamp := @nFSUnused;
  end
  else
  begin
    qTaxList   := @(CurSalesTaxList);
    qTotal     := @curSale.nTotal;
    qMedia     := @curSale.nMedia;
    qAmountDue := @curSale.nAmountDue;
    qSubTotal  := @curSale.nSubtotal;
    qTax       := @curSale.nTlTax;
    qFoodStamp := @curSale.nFSSubtotal;
    ClearTaxListEntries(qFSTaxList);
  end;

  qFoodStamp^ := 0;
  qSubTotal^ := 0;
  qMedia^ := 0;
  FuelSubTotal := 0;

  EnterCriticalSection(CSTaxList);  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  try // PROGRAMMING WARNING:  Do not exit this try block without leaving critical section.
    ClearTaxListEntries(qTaxList);

    curSale.FoodStampMediaAmount := 0.0;
    curSale.FuelMediaAmount      := 0.0;

    for i:= 0 to CurSalelist.Count-1 do
    begin
      SD := CurSaleList.Items[i];
      // For "restricted only", filter out all items that are not media or restricted department sales.
      if (bRestrictedOnly) then
      begin
        {$IFDEF MULTI_TAX}
        if (SD^.LineType <> 'MED') and (SD^.LineType <> 'TAX') then
        {$ELSE}
        if (SD^.LineType <> 'MED') then
        {$ENDIF}
        begin
          // Search for a matching restricted department.  If one is not found, skip item.
          // Note: Count is at least one, or procedure exits above.
          for j := 0 to RestrictedDeptList.Count - 1 do
          begin
            q := RestrictedDeptList.Items[j];
            if (q^.DeptNo = SD^.DeptNo) then break;
          end;
          if (q^.DeptNo <> SD^.DeptNo) then continue; // Skip unrestricted department item.
        end;
      end; // if (bRestrictedOnly)
      if ((SD^.LineType = 'FUL') or (SD^.LineType = 'PPY') or (SD^.LineType = 'DSG') or (SD^.LineType = 'DS$')) then
        FuelSubTotal := FuelSubTotal + SD^.ExtPrice;
      if bUseFoodStamps and bitset(SD^.mediarestrictioncode, MRC_bSNAP) and ((SD^.LineType = 'DPT') or (SD^.LineType = 'PLU') or (SD^.LineType = 'FUL') or (SD^.LineType = 'DSC')) then
        qFoodStamp^ := qFoodStamp^ + SD^.ExtPrice;

      { TODO : GiftCard - will the following work for media returns? }
      if (SD^.LineType = 'MED') then
        qMedia^    := POSRound((qMedia^    + SD^.ExtPrice), 2)
      else
      {$IFDEF MULTI_TAX}
        {$IFDEF PDI_PROMOS}
          if (SD^.LineType <> 'TAX') and (SD^.LineType <> 'DSC') then
        {$ELSE}  // PDI_PROMOS
          if (SD^.LineType <> 'TAX') then
        {$ENDIF}  // PDI_PROMOS
      {$ELSE} // MULTI_TAX
        {$IFDEF PDI_PROMOS}
          if (SD^.LineType <> 'DSC') then
        {$ENDIF}  // PDI_PROMOS
      {$ENDIF}  // MULTI_TAX
            qSubTotal^ := POSRound((qSubTotal^ + SD^.ExtPrice), 2);

      // Calculate food stamp media already tendered.
      if SD^.LineType = 'MED' then
      begin
        try
          MediaNumber := Trunc(SD^.Number);
        except
          MediaNumber := 0;
        end;
        if (MediaNumber in [FOOD_STAMP_MEDIA_NUMBER, EBT_FS_MEDIA_NUMBER]) then
          curSale.FoodStampMediaAmount := POSRound((curSale.FoodStampMediaAmount + SD^.ExtPrice), 2);
        // Calculate fuel-only media already tendered.
        if (MediaNumber = DEFAULT_GIFT_CARD_MEDIA_NUMBER) then
          curSale.FuelMediaAmount := curSale.FuelMediaAmount + POSRound((curSale.FoodStampMediaAmount + SD^.ExtPrice), 2);
      end;

      if (SD^.LineType = 'DPT') or (SD^.LineType = 'PLU') or (SD^.LineType = 'FUL') or
         (SD^.LineType = 'DSC') or (SD^.LineType = 'PPY') or (SD^.LineType = 'PRF')  then
      begin
        AllocateTaxes(SD, qTaxList, curSale.bSalesTaxXcpt);

        if ((not bRestrictedOnly) and bitset(SD^.mediarestrictioncode, MRC_bSNAP)) then
          AllocateTaxes(SD, qFSTaxList, curSale.bSalesTaxXcpt);
      end;  // if (SD^.LineType = ...
    end;  // for i:= 0 to CurSalelist.Count-1

    // Calculate tax as if food stamp media were not exempt
    NonAdjustedTax := ComputeTaxes(qTaxList);

    // Taxable amounts have been calculated for each tax level.
    // Reduce taxable amounts for any prior food stamp media.
    TaxableSalesToReduce := curSale.FoodStampMediaAmount;
    for t := 0 to qTaxList^.Count-1 do
    begin
      ST := qTaxList^.Items[t];
      // Skip taxes calculated on item counts (instead of amounts) - these do not apply to food stamps.
      if (ST^.TaxType = TAX_TYPE_QTY) then
        continue;
      FSST := qFSTaxList^.Items[t];  // represents only the food stampable portion of the sale
      if (Abs(FSST^.Taxable) >= Abs(TaxableSalesToReduce)) then
      begin
        ST^.FSTaxExemptSales := ST^.FSTaxExemptSales + TaxableSalesToReduce;
        //ST^.Taxable := ST^.Taxable - TaxableSalesToReduce;
        if (t <> 0) then
          ST^.Taxable := ST^.Taxable - TaxableSalesToReduce;
        {$IFNDEF MULTI_TAX}
        break;
        {$ENDIF}
      end
      else
      begin
        ST^.FSTaxExemptSales := ST^.FSTaxExemptSales + FSST^.Taxable;
        if (t <> 0) then
          ST^.Taxable := ST^.Taxable - FSST^.Taxable;
        TaxableSalesToReduce := TaxableSalesToReduce - FSST^.Taxable;
      end;
    end;

    // Calculate tax on adjusted taxable amounts
    for i:= 0 to qTaxList^.Count-1 do
    begin
      ST := qTaxList^.Items[i];
      FSST := qFSTaxList^.Items[i];
      FSST^.TaxCharged := ST^.TaxCharged;
      ST^.TaxCharged := 0;
    end;

    qTax^ := ComputeTaxes(qTaxList);

    UpdateZLog('RecomputeSaleTotal - subtotal: %.2f, tax: %.2f, total: %.2f',[qSubTotal^, qTax^, qTotal^]);
    qTotal^ := POSRound((qSubTotal^ + qTax^), 2);

    TaxExempted := NonAdjustedTax - qTax^;
    // Reduce tax amounts for any prior food stamp media.
    TaxAmountToReduce := TaxExempted;
    for t := 1 to qTaxList^.Count - 1 do
    begin
      ST := qTaxList^.Items[t];
      FSST := qFSTaxList^.Items[t];  // record indicates tax that would have been charged without food stamp exemption
      TaxReduction := FSST^.TaxCharged - ST^.TaxCharged;
      if (Abs(TaxReduction) >= Abs(TaxAmountToReduce)) then
      begin
        ST^.FSTaxExemptAmount := ST^.FSTaxExemptAmount + TaxAmountToReduce;
        {$IFNDEF MULTI_TAX}
        break;
        {$ENDIF}
      end
      else
      begin
        ST^.FSTaxExemptAmount := ST^.FSTaxExemptAmount + TaxReduction;
        TaxAmountToReduce := TaxAmountToReduce - TaxReduction;
      end;
    end;

  except
    on E: Exception do
    begin
    TaxExempted := 0.0;
      UpdateExceptLog('ReComputeSaleTotal - cannot calculate tax - ' + E.Message);
      UpdateZLog('ReComputeSaleTotal - cannot calculate tax - %s - %s', [E.ClassName, E.Message]);
      DumpTraceback(E);
    end;
  end; // try/except
  LeaveCriticalSection(CSTaxList);  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  if (bRestrictedOnly) then
  begin
    // Determine the amount of media already processed with a restricted card.  Only unrestricted prior media
    // tendered is decremented from restricted amounts in the sales list to determine the effective restricted amount.
    PriorRestrictedMedia := 0.0;
    for j := 0 to qClient^.GiftCardUsedList.Count - 1 do
    begin
      gd := qClient^.GiftCardUsedList.Items[j];
      if ((gd^.RestrictionCode = RC_NO_SIN) and (gd^.PriorValue > gd^.FaceValue)) then
          PriorRestrictedMedia := PriorRestrictedMedia + gd^.PriorValue - gd^.FaceValue;
    end;
    qAmountDue^ := Max((qTotal^ - (qMedia^ - PriorRestrictedMedia)), 0);  // no negative restricted amounts
  end
  else
  begin
    curSale.nFuelSubTotal := FuelSubTotal;
    qAmountDue^ := qTotal^ - qMedia^;
    // Determine tax on food stamp items
    QualifyingFSTax := ComputeTaxes(qFSTaxList);

    curSale.nFSTax := QualifyingFSTax - TaxExempted;

    if (PPTrans <> nil) then
    begin
      PPTrans.PinPadFSAmount := curSale.nFSSubtotal - curSale.FoodStampMediaAmount;
      PPTrans.PinPadFuelAmount := curSale.nFuelSubtotal - curSale.FuelMediaAmount;
    end;
  end;

  AddTaxList;

  lastitemidx := -1;
  // Let pin pad class know about new sales item and totals (so it can update its display).
  if ((CurSaleList.Count > 0) and (not bRestrictedOnly)) then
  begin
    for i := 0 to Pred( CurSaleList.Count ) do
    begin
      SD := pSalesData( CurSaleList.Items[ i ] );
      if SD.LineType = 'TAX' then
      begin
        lastitemidx := i - 1;
        break;
      end;
    end;
    if lastitemidx > -1 then
      DisplaySaleDataToPinPad(PPTrans, CurSaleList.Items[ lastitemidx ]);
  end;

  UpdateZLog('RecomputeSaleTotal - exit - nCurAmountDue: %.2f', [curSale.nAmountDue]);
end;



{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyERC
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyERC();
begin
  ErrorCorrect();
end;

procedure TfmPOS.ErrorCorrect();
var
  CurPtr : integer;
  CompareLinkedPLUNo : double;
//20080102b  voidedCnt : integer;  //20071119c
  j : integer;  //20071119c
  compareSeqLink : short;
  saleCnt : integer;  //20071120a
  totalsLines : integer;  //20071120a
  bItemFound : boolean;  //20080102b
  qSalesData : pSalesData;
  VoidedItemActivationState : TActivationState;
  VoidedItemLineID : integer;
  VoidedItemCCPin : string;
  CurSaleData : pSalesData;
begin

  CurPtr := POSListBox.ItemIndex;   //grab the ptr from the item highlighted in the list box
  UpdateZLog(Format('Errorcorrect - Called on line %d, SaleState = %s',[CurPtr, SaleStateStr(SaleState)]));
  //20071120a...
//  if CurPtr > (POSListBox.Items.Count - 4) then
//    CurPtr := POSListBox.Items.Count - 4;
  // Verify that highlighted area is not below the last item on the sales list
  if bUseFoodStamps then
    totalsLines := 4
  else
    totalsLines := 3;
  if CurPtr >= (POSListBox.Items.Count - totalsLines) then
    exit;
  //...20071120a

  //20071119c...
//  CurSaleData := CurSaleList.Items[CurPtr];
//20080102b  voidedCnt := 0;
  //20071120a...
//  for j := 0 to CurPtr do
//  begin
//    CurSaleData := CurSaleList.Items[j];
//    if CurSaleData^.SaleType = 'Void' then
//      inc(voidedCnt);
//  end;
//  CurSaleData := CurSaleList.Items[CurPtr + voidedCnt];
  // Adjust for difference in CurSaleList vs POSListBox (some items in CurSaleList are not on POSListBox)
  saleCnt := 0;
  //20080102b...
//  j := 0;
//  while saleCnt <= CurPtr do
//  begin
//    CurSaleData := CurSaleList.Items[j];
//    if ((CurSaleData^.SaleType = 'Void') or
//        (CurSaleData^.SaleType = 'Info')) then
//      inc(voidedCnt)
//    else
//      inc(saleCnt);
//    inc(j);
//  end;
//  CurSaleData := CurSaleList.Items[saleCnt - 1 + voidedCnt];
  CurSaleData := nil;
  bItemFound := False;
  for j := 0 to CurSaleList.Count - 1 do
  begin
    CurSaleData := CurSaleList.Items[j];
    if (CurSaleData^.SaleType <> 'Info') then
      Inc(saleCnt);
    if (saleCnt = CurPtr + 1) then
    begin
      bItemFound := True;
      break;
    end;
  end;
  if (not bItemFound) then
    exit;
  //...20080102b
  //...20071120a
  //...20071119c

  if (not ((CurSaleData^.SaleType = 'Sale') or
     ((CurSaleData^.SaleType = 'Rtrn') and (CurSaleData^.ActivationState <> asActivationDoesNotApply)))) then
    Exit;
  if CurSaleData^.LineVoided = True then
    Exit;
  {$IFDEF ODOT_VMT}
  if (CurSaleData^.LineType = 'DSV') then
    exit;
  {$ENDIF}

  nModifierValue := CurSaleData^.PLUModifier;  //20060713c  //GMM:  Added to properly identify modifier on Void item
  
  VoidedItemActivationState := CurSaleData^.ActivationState;
  VoidedItemLineID := CurSaleData^.LineID;
  VoidedItemCCPin := CurSaleData^.ccPIN;

  if CurSaleData^.SeqLink = 0 then
    PostItemVoid(CurSaleData)
  else
  begin
    compareSeqLink := abs(CurSaleData^.SeqLink);
    for j := 0 to CurSaleList.Count - 1 do
    begin
      CurSaleData := CurSaleList.Items[j];
      if (abs(CurSaleData^.SeqLink) = compareSeqLink) and not CurSaleData^.LineVoided then
        PostItemVoid(CurSaleData);
    end;
  end;

  CurSaleData := CurSaleList.Items[CurPtr];
  if CurSaleData^.LinkedPLUNo > 0 then  //  also need to void the linked item -it's either above or below in the saleslist
  begin
    CompareLinkedPLUNo := CurSaleData^.LinkedPLUNo;
    while True do
    begin
      if CurPtr > 0 then
      begin
        CurSaleData := CurSaleList.Items[CurPtr-1];
        if CompareLinkedPLUNo = CurSaleData^.Number then
        begin
          PostItemVoid(CurSaleData);
          break;
        end;
      end;
      if (POSListBox.Items.Count - 1) > CurPtr then
      begin
        CurSaleData := CurSaleList.Items[CurPtr+1];
        if CompareLinkedPLUNo = CurSaleData^.Number then
        begin
          PostItemVoid(CurSaleData);
          break;
        end;
      end;
      break;
    end;
  end;
  {$IFDEF ODOT_VMT}
  // Check for discount associated with fuel
  CurSaleData := CurSaleList.Items[CurPtr];
  if ((CurPtr < (POSListBox.Items.Count - 4)) and (CurSaleData^.LineType = 'FUL')) then
  begin
    CurSaleData := CurSaleList.Items[CurPtr+1];
    if ((CurSaleData^.LineType = 'DSV') and (not CurSaleData^.LineVoided) and (CurSaleData^.SaleType = 'Sale')) then
      PostItemVoid(CurSaleData);
  end;
  {$ENDIF}
  {$IFDEF PDI_PROMOS}
  CheckforPDIAdjustment;
  {$ENDIF}

  ClearEntryField;
  // If item being error corrected was an activation type, then
  // the last item on the sales list is the voided (negative amount)
  // activation entry.
  // This "void" entry now needs to be queued to the credit server.
  if (CurSaleList.Count > 0) then
  begin
    qSalesData := nil;
    for j := CurSaleList.Count - 1 downto 0 do
    begin
      qSalesData := CurSaleList.Items[j];
      if ((qSalesData^.LineType <> 'MED') and (qSalesData^.LineType <> 'TAX')) then
        break;
    end;
    if (qSalesData <> nil) and (qSalesData^.ActivationState = asActivationNeeded) then
    begin
      {$IFDEF UNTESTED_CODE}
      POSError('De-Activation required');
      {$ENDIF}
      qSalesData^.LineID := VoidedItemLineID;
      qSalesData^.ccPIN := VoidedItemCCPin;
      if (qSalesData^.Qty > 0) then  // if a void of a return
      begin
        qSalesData^.ActivationState := VoidedItemActivationState;
      end
      else if (VoidedItemActivationState = asActivationRejected) then
      begin
        // Not as critical of an error (e.g., card attempted to activate was
        // already active), so no need  to queue a deactivation (void) request;
        qSalesData^.ActivationState := VoidedItemActivationState;  // prevents end of receipt summary of failed activations
      end
      else if (SaleState = ssTender) then
      begin
        FCardActivationTimeOut := Now() + PRODUCT_ACTIVATION_TIMEOUT_DELTA;
        QueueActivationRequest(qSalesData);
        qSalesData := AddActivationMessageLine('Voiding...');
      end
      else
      begin
        qSalesData^.ActivationState := asActivationDoesNotApply;
        if (VoidedItemLineID > 0) then
          AlterActivationMessageLine('Error Corrected', @(CurSaleList), VoidedItemLineID, True);
      end;
      {$IFDEF FUEL_PRICE_ADJUST}
      DisplaySaleList(qSalesData,False);
      {$ELSE}
      DisplaySaleList(qSalesData);
      {$ENDIF}
      POSListBox.Refresh();
    end;
  end;
  CheckSaleList;

end;

function TfmPOS.GetLineID() : integer;
{
Generate an ID for a sales list item that will remain unique in the system for the duration
of the sale.
}
var
  id : integer;
begin
  ID := Round(100000000.0 * (ThisTerminalNo + Frac(Now())));
  if ID = lastLineID then inc( ID );
  lastlineID := ID;
  Result := ID;
end;  //     function GetLineID

{-----------------------------------------------------------------------------
  Name:      TfmPOS.CheckSaleList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.CheckSaleList;
var
  ndx         : short;
  sd          : pSalesData;
  CheckList     : TList;
  j : integer;
begin
  UpdateZLog('  CheckSaleList - Enter - %d items', [CurSaleList.Count]);
  // make a copy of the salelist but don't copy any auto disc records
  // this would also be a good spot to clean up any void records if we want

  CheckList := TList.Create;
  if CurSaleList.Count > 0 then
  for ndx := 0 to (CurSaleList.Count - 1) do
    begin
      SD := CurSaleList.Items[ndx];
      if SD^.LineType = 'DSC' then
      begin
      if SD^.AutoDisc <> True then
        begin
          SD^.QtyUsedForSplitOrMM := 0;
          CheckList.Capacity := CheckList.Count;
          CheckList.Add(SD)
        end
      else
        begin
          UpdateZLog('  CheckSaleList - Disposing of %s, %.2f because AutoDisc = True', [SD^.Name, SD^.ExtPrice]);
        Dispose(SD);
    end;
      end
      else
      begin
        SD^.QtyUsedForSplitOrMM := 0;
        CheckList.Capacity := CheckList.Count;
        CheckList.Add(SD)
      end;

    end;
  UpdateZLog('  CheckSaleList - Enter - %d items', [CurSaleList.Count]);

  CurSaleList.Clear;
  CurSaleList.Capacity := CurSaleList.Count;
  POSListBox.Clear;

  for ndx := 0 to (CheckList.Count - 1) do
    begin
      SD := CheckList.Items[ndx];
      CheckList.Items[ndx] := nil;
      CurSaleList.Capacity := CurSaleList.Count;
      j := CurSaleList.Add(SD);
      UpdateZLog('  CheckSaleList - Added %s - %.2f in position %d', [SD^.Name, SD^.ExtPrice, j]); 
      SD^.SeqNumber := CurSaleList.Count;

//      if (CurSaleData^.LineType = 'DSC') or (CurSaleData^.LineType = 'MXM') then
// dca 1-19 i don't tink we need to check mxm - they are handled by check for adjustment
      if (SD^.LineType = 'DSC') and (SD^.AutoDisc = False) then
        begin
          {$IFNDEF PDI_PROMOS}
          RecomputeDiscount(SD);
          {$ENDIF}
          if SD^.ExtPrice = 0 then
            begin
              CurSaleList.Delete(CurSaleList.Count-1);
              Dispose(SD);
              continue;
            end;
        end;

      if (SD^.LineType = 'TAX') then
      begin
        //  Tax lines are not individually displayed (total tax displayed in DisplaySaleTotal)
      end
      else if (SD^.LineType = 'MED') then
        DisplayMedia(SD)
      else
      {$IFDEF FUEL_PRICE_ROLLBACK}
      DisplaySaleList(SD, False);
      {$ELSE}
      DisplaySaleList(SD);
      {$ENDIF}
      ComputeSaleTotal;
      {$IFNDEF PDI_PROMOS}
      // need to add handling for fuel prepay
      if ((SD^.LineType = 'PLU') or (SD^.LineType = 'FUL')) and (SD^.LineVoided = False) and (SD^.SaleType = 'Sale') then
        CheckForAdjustment(SD);
      {$ENDIF}

    end;
  CheckList.Pack;
  if CheckList.Count > 0 then
  begin
    UpdateExceptLog('TfmPOS.CheckSaleList - warning, local ''CheckList'' isn''t empty');
    for ndx := 0 to (CheckList.Count - 1) do
    begin
      SD := CheckList[ndx];
      try
        UpdateExceptLog('   %03i:  %15f  %-30s', [ndx, SD^.Number, SD^.Name]);
      except
        on E : Exception do UpdateExceptLog('   %03i:  unknown due to exception %s', [ndx, E.Message])
      end;
      dispose(CheckList[ndx]);
    end;
  end;

  CheckList.Free ;
  UpdateZLog('  CheckSaleList - Exit - %d items', [CurSaleList.Count]);

end;

{$IFNDEF PDI_PROMOS}
{-----------------------------------------------------------------------------
  Name:      TfmPOS.RecomputeDiscount
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.RecomputeDiscount(const CurSaleData : pSalesData);
var
  SD : pSalesData;
  ndx : integer;
begin

  curSale.nDiscountableTl := 0;
  if CurSaleList.Count > 1 then
    begin
      for ndx := 0 to (CurSaleList.Count - 1) do
        begin
          SD := CurSaleList.Items[ndx];
          if (SD^.LineType = 'DSC') then
            begin
              if SD^.AutoDisc = False then
                curSale.nDiscountableTl := 0;
            end
          else if SD^.LineType = 'MXM' then
      //      nDiscountableTl := 0
          else if (SD^.Discable = True) and (SD^.SaleType = 'Sale') and (SD^.LineVoided = False) then
            curSale.nDiscountableTl := curSale.nDiscountableTl + SD^.ExtPrice;
        end;
    end;
  if curSale.nDiscountableTl = 0 then
    begin
      CurSaleData^.Price := 0;
    end
  else
    begin
      if CurSaleData^.SavDiscType = 'P' then
        begin
          CurSaleData^.Price := (curSale.nDiscountableTl * CurSaleData^.SavDiscAmount) * -1;
        end
      else
        begin  // if dollar discount is > than remaining discable tl then delete it
          if CurSaleData^.SavDiscAmount > curSale.nDiscountableTl then
            CurSaleData^.Price := 0
          else
            CurSaleData^.Price := (CurSaleData^.SavDiscAmount) * -1 ;
        end;
    end;
  CurSaleData^.ExtPrice := CurSaleData^.Price;

end;
{$ENDIF}

{-----------------------------------------------------------------------------
  Name:      TfmPOS.PostItemVoid
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.PostItemVoid(const CurSaleData : pSalesData);
var
  VoidSaleData : pSalesData;
  AccessCode     : string;
begin
  sLineType := CurSaleData^.LineType;
  AccessCode := CurSaleData^.CCCardName;
  sSaleType := 'Void';
  if sLineType = 'DPT' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBDeptQuery do
    begin
      ParamByName('pDeptNo').AsInteger := Trunc(CurSaleData^.Number);
      Open;
      GetDept(POSDataMod.IBDeptQuery, @Dept);
      Close;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end
  else if sLineType = 'PLU' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBPLUQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('Select * from PLU where PLUNo = :pPLUNo');
      ParamByName('pPLUNo').AsCurrency := CurSaleData^.Number;
      Open;
      GetPLU(POSDataMod.IBPLUQuery, @PLU);
      nLinkedPLUNo := PLU.LINKEDPLU;
      PLU.DeptNo := CurSaleData^.DeptNo;
      PLU.SplitQty := CurSaleData^.SplitQty;
      PLU.SplitPrice := CurSaleData^.SplitPrice;
      close;
      with POSDataMod.IBDeptQuery do
      begin
        ParamByName('pDeptNo').AsInteger := PLU.DeptNo;
        Open;
        GetDept(POSDataMod.IBDeptQuery, @Dept);
        close;
      end;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
    //Test for carwash
    if not POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.StartTransaction;
    with POSDataMod.IBTempQry1 do
    begin
      close;SQL.Clear;
      SQL.Add('Select * from Grp where GrpNo = :pGrpNo');
      parambyname('pGrpNo').AsString := inttostr(Dept.GRPNO);
      open;
      if fieldbyname('Fuel').AsInteger = 3 then
      begin
        close;
        if AccessCode <> '' then fmCWAccessForm.VoidCarwashCode(AccessCode);
      end
      else
        close;
    end;
    if POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.Commit;
  end
  else if sLineType = 'FUL' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBDeptQuery do
    begin
      ParamByName('pDeptNo').AsInteger := Trunc(CurSaleData^.Number);
      Open;
      GetDept(POSDataMod.IBDeptQuery, @Dept);
      close;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
    nPumpNo := CurSaleData^.PumpNo;
    SendFuelMessage(nPumpNo, PMP_RELEASE, NOAMOUNT, CurSaleData^.FuelSaleID, curSale.nTransNo, NODESTPUMP);
  end
  else if sLineType = 'PRF' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBDeptQuery do
    begin
      ParamByName('pDeptNo').AsInteger := Trunc(CurSaleData^.Number);
      Open;
      GetDept(POSDataMod.IBDeptQuery, @Dept);
      close;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
    nPumpNo := CurSaleData^.PumpNo;
    SendFuelMessage(nPumpNo, PMP_RELEASE, NOAMOUNT, CurSaleData^.FuelSaleID, curSale.nTransNo, NODESTPUMP  );
  end
  else if sLineType = 'PPY' then
  begin
    CurSaleData^.Qty := 1;
    nPumpNo := CurSaleData^.PumpNo;
    SendFuelMessage(nPumpNo, PMP_RELEASE, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
  end
  else if sLineType = 'DSC' then
    curSale.nDiscountableTl := CurSaleData^.SavDiscable
  //DSG
  else if sLineType = 'DSG' then
  begin { TODO -oGary -cCheck : DSG - Should I do something here? }
  end
  //DSG
  {$IFDEF CASH_FUEL_DISC}
  else if sLineType = 'DS$' then
  begin // (todo) - Anything to do here?
  end
  {$ENDIF}
  {$IFDEF ODOT_VMT}
  else if sLineType = 'DSV' then
  begin // (todo) - Anything to do here?
  end
  {$ENDIF}
  else if sLineType = 'MXM' then
    curSale.nDiscountableTl := CurSaleData^.SavDiscable
  else Exit;

  CurSaleData^.LineVoided := True;   { set current record to voided }
  If sLineType <> 'FUL' Then
  Begin
    nQty := CurSaleData^.Qty * -1;
    nAmount := CurSaleData^.Price;
    nExtAmount   := CurSaleData^.ExtPrice * -1;
  End
  Else
  Begin
      { Correction B.Bartlome : }
    nPumpVolume  := CurSaleData^.Qty;
    nPumpAmount  := CurSaleData^.Price;
    nExtAmount   := CurSaleData^.ExtPrice;
  End;

  VoidSaleData := AddSaleList;
  //gift-20040708...
  VoidSaleData^.CCCardNo := CurSaleData^.CCCardNo;  // (Applies to gift cards) Associate with same card number that was voided
  VoidSaleData^.GCMSRData := CurSaleData^.GCMSRData;
  VoidSaleData^.CCExpDate := CurSaleData^.CCExpDate;
  VoidSaleData^.CCCardName := CurSaleData^.CCCardName;
  VoidSaleData^.CCCardType := CurSaleData^.CCCardType;
  VoidSaleData^.CCEntryType := CurSaleData^.CCEntryType;
  VoidSaleData^.ActivationTransNo := CurSaleData^.ActivationTransNo;
  //...gift-20040708
  PoleMdse(VoidSaleData, SaleState);
  ComputeSaleTotal;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyDSC
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyDSC(const sKeyVal : string);
var
  SD : pSalesData;
  ndx : integer;
  nKeyVal : integer;
begin

  try
    nKeyVal := StrToInt(sKeyVal);
  except
    nKeyVal := 0;
  end;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBDiscQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from Disc where DiscNo = :pDiscNo');
      ParamByName('pDiscNo').AsInteger := nKeyVal;
      Open;
      if EOF then
      begin
        Close;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        POSError('Discount Not Found');
        Exit;
      end
      else
      begin
        DisDISCNO := fieldbyname('DiscNo').Asinteger;
        DisNAME := fieldbyname('Name').Asstring;
        DisREDUCETAX := fieldbyname('ReduceTax').Asinteger;
        DisAMOUNT := fieldbyname('Amount').Ascurrency;
        DisRECTYPE := fieldbyname('RecType').AsString;
        close;
      end;
    end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  curSale.nDiscountableTl := 0;

  for ndx := 0 to (CurSaleList.Count - 1) do
    begin
      SD := CurSaleList.Items[ndx];
      if SD^.LineType = 'DSC' then
      begin
        if SD^.AutoDisc = False then
          curSale.nDiscountableTl := 0 ;
      end
      else if (SD^.LineType = 'MXM') or (SD^.LineType = 'PPY')
        or (SD^.LineType = 'PRF') then//if SD^.LineType = 'MXM' then
   //     nDiscountableTl := 0
      else if (SD^.Discable = True) and (SD^.SaleType = 'Sale') and (SD^.LineVoided = False) then
        curSale.nDiscountableTl := curSale.nDiscountableTl + SD^.ExtPrice;
    end;

  if curSale.nDiscountableTl = 0 then
    Exit;

  nDiscNo := StrToInt(sKeyVal);

  if DisAmount < 1 then
    begin
      if sEntry = '' then
        begin
          POSError('Please Enter An Amount');
          Exit;
        end;
      try
        nDiscAmount := StrToFloat(sEntry);
      except
        nDiscAmount := 0;
      end;
      if nDiscAmount = 0 then
        begin
          POSError('Please Enter An Amount');
          Exit;
        end;
      nDiscAmount := nDiscAmount / 100;
    end
  else
    nDiscAmount := DisAmount / 100 ;

  if DisRecType = 'P' then
    nAmount := (curSale.nDiscountableTl * nDiscAmount) * -1
  else
    nAmount := nDiscAmount * -1;

  nAmount := POSRound(nAmount,2);

  if abs(nAmount) > abs(curSale.nDiscountableTl) then
    begin
      POSError('Over Discount Limit!');
      Exit;
    end;


  if nAmount <> 0 then
    begin
      nQty := 1;
      nDiscType := DisRecType;
      sLineType := 'DSC';
      sSaleType := 'Sale';
      SD := AddSaleList;

      PoleMdse(SD, SaleState);
      ComputeSaleTotal;
      ClearEntryField;
      curSale.nDiscountableTl := 0;
   end;


end;

{$IFDEF FUEL_PRICE_ROLLBACK}
procedure TfmPOS.ProcessKeyAFD();
begin
  AdjustFuelPriceOnSalesList(-1);  // No media number specified causes toggle between "cash" and "non-cash" media.
end;  // Procedure ProcessKeyAFD

procedure TfmPOS.AdjustFuelPriceOnSalesList(const FuelMediaNo : integer);
{
Alter the price on the selected fuel price item of the sales list according to the specified media.
(If FuelMediaNo is negative, then toggle between discounted and non-discounted prices.
}
var
  iCurPtr : integer;
  iFuelGradeNo : integer;
  cUnDiscountedPrice : currency;
  cDiscountedPrice : currency;
  cNewAmount : currency;
  cAdjustedPrice : currency;
begin
  iCurPtr := POSListBox.ItemIndex;   //grab the ptr from the item highlighted in the list box
  if ((iCurPtr < 0) or (iCurPtr > (POSListBox.Items.Count - 4))) then
  begin
    if (FuelMediaNo < 0) then
      POSError('Select Fuel Item From Sales List');
    exit;
  end;

  CurSaleData := CurSaleList.Items[iCurPtr];

  // Verify that item is a fuel sale.
  if ((not CurSaleData^.LineVoided) and (CurSaleData^.LineType = 'FUL') and (CurSaleData^.SaleType = 'Sale')) then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBGradeQuery do
    begin
      // Determine the fuel grade.
      iFuelGradeNo := 0;
      Close();
      SQL.Clear();
      SQL.Add('select Min(P.GradeNo) as FuelGradeNo from FuelTran F join PumpDef P');
      SQL.Add('  on F.PumpNo = P.PumpNo and F.HoseNo = P.HoseNo');
      SQL.Add('  where F.SaleID = :pSaleID');
      ParamByName('pSaleID').AsInteger := CurSaleData^.FuelSaleID;
      Open();
      if (not EOF) then
        iFuelGradeNo := FieldByName('FuelGradeNo').AsInteger;
      Close();

      // Determine the un-discounted price
      cUnDiscountedPrice := 0.0;
      SQL.Clear();
      SQL.Add('select CashPrice from Grade where GradeNo = :pGradeNo');
      ParamByName('pGradeNo').AsInteger := iFuelGradeNo;
      Open();
      if (not EOF) then
        cUnDiscountedPrice := FieldByName('CashPrice').AsCurrency;
      Close();

      // Determine discounted price
      cDiscountedPrice := cUnDiscountedPrice;
      SQL.Clear();
      SQL.Add('select Amount from Disc where DiscNo = :pDiscNo and RecType = :pRecType');
      ParamByName('pDiscNo').AsInteger := CASH_EQUIV_FUEL_DISC_NO + iFuelGradeNo;
      ParamByname('pRecType').AsString := 'F';
      Open();
      if (not EOF) then
        cDiscountedPrice := cDiscountedPrice - FieldByName('Amount').AsCurrency;
    end;  // with
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;

    // Check to see if different prices are set for the grade
    if ((cUnDiscountedPrice > 0.0) and (cDiscountedPrice > 0.0) and (cUndiscountedPrice <> cDiscountedPrice)) then
    begin
      // Switch price shown on the display list.
      if (CurSaleData^.Price = cUnDiscountedPrice) then
        cAdjustedPrice := cDiscountedPrice
      else if (CurSaleData^.Price = cDiscountedPrice) then
        cAdjustedPrice := cUnDiscountedPrice
      else
        cAdjustedPrice := CurSaleData^.Price;
      if (cAdjustedPrice = CurSaleData^.Price) then
      begin
        // Should not get here (unless pump prices just adjusted).
        if (FuelMediaNo < 0) then
          POSError('This Fuel Price Is Not Adjustable');
      end
      else
      begin
        // Adjust the price.
        CurSaleData^.Price := cAdjustedPrice;
        cNewAmount := POSRound(CurSaleData^.Qty * CurSaleData^.Price, 2);
        CurSaleData^.ExtPrice := cNewAmount;
        POSListBox.DeleteSelected();
        if (iCurPtr < POSListBox.Count) then
          POSListBox.ItemIndex := iCurPtr;
        DisplaySaleList(True);
        PoleMdse();
        ComputeSaleTotal();
        POSListBox.Refresh;
      end;
    end  // if discounted price differs
    else
    begin
      if (FuelMediaNo < 0) then
        POSError('Multiple Prices Not Configured For Grade');
    end;
  end  // if item in sales list is for fuel
  else
  begin
    if (FuelMediaNo < 0) then
      POSError('Item Selected From Sales List Must Be For Fuel');
  end;

end;  // procedure AdjustFuelPriceOnSalesList

function TfmPOS.AdjustFuelPriceForTender(const AmountToTender : currency;
                                         const FuelMediaNo : integer;
                                         const FuelCardType : string) : boolean;
{
Adjust fuel prices (and corresponding amounts) based on tender (including any prior partial tenders).
This function should be called for the last tender and will return true unless the user rejects any
identified price adjustments.
}
var
  cQualifyingAmount : currency;
  VolumeByGrade : array [0..MAX_GRADE_NUMBER] of currency;
  qSalesData : pSalesData;
  iGradeNo : integer;
  cMaxPrice : currency;
  cUnDiscountedPrice : currency;
  cDiscountedPrice : currency;
  cRequiredPrice : currency;
  cDiscountedFuelAmount : currency;
  cNewAmount : currency;
  iFuelGradeNo : integer;
//  cDiscountAmount : currency;
  bFullCardTender : boolean;  //20070615a
  j : integer;
  RetValue : boolean;
begin
  RetValue := True;  // Initial Assumption (change if user refuses adjustment).
  for j := 0 to MAX_GRADE_NUMBER do
    VolumeByGrade[j] := 0.0;
  if (PaymentQualifiesForDiscountedFuelPrice(FuelMediaNo, FuelCardType)) then
    cQualifyingAmount := AmountToTender
  else
    cQualifyingAmount := 0.0;
  // Sum media tendered (or about to be tendered) and total fuel volume (by grade).
  for j := 0 to CurSaleList.Count - 1 do
  begin
    qSalesData := CurSaleList.Items[j];
    if (qSalesData^.LineType = 'MED') then
    begin
      if (PaymentQualifiesForDiscountedFuelPrice(Round(qSalesData^.Number), qSalesData^.CCCardType)) then
        cQualifyingAmount := cQualifyingAmount + qSalesData^.ExtPrice;
    end
    else if ((qSalesData^.LineType = 'FUL') and (not qSalesData^.LineVoided) and (qSalesData^.SaleType = 'Sale')) then
    begin
      // Determine grade of fuel (from Fuel SaleID in sales list entry.
      iGradeNo := 0;
      try
        if not POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.StartTransaction;
        with POSDataMod.IBGradeQuery do
        begin
          Close();
          SQL.Clear();
          SQL.Add('select Min(P.GradeNo) as GradeNo from FuelTran F join PumpDef P');
          SQL.Add('  on F.PumpNo = P.PumpNo and F.HoseNo = P.HoseNo');
          SQL.Add('  where F.SaleID = :pSaleID');
          ParamByName('pSaleID').AsInteger := qSalesData^.FuelSaleID;
          Open();
          if (not EOF) then
            iGradeNo := FieldByName('GradeNo').AsInteger;
          Close();
        end;  // with
      except
        iGradeNo := 0;
      end;
      if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
      if (iGradeNo > MAX_GRADE_NUMBER) then
        iGradeNo := 0;
      VolumeByGrade[iGradeNo] := VolumeByGrade[iGradeNo] + qSalesData^.Qty
    end;  // else if ((qSalesData^.LineType = ...
  end;  // for j := 0 to CurSaleList.Count - 1
  // Determine discounted amount for each fuel grade.
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBGradeQuery do
  begin

    try
      cMaxPrice := 0.0;
      Close();
      SQL.Clear();
      SQL.Add('select Max(CashPrice) as MaxCashPrice from Grade');
      Open();
      if (not EOF) then
        cMaxPrice := FieldByName('MaxCashPrice').AsCurrency;
      Close();
    except
      cMaxPrice := 0.0;
    end;

    // Determine total fuel amount (if discounted price appled to all fuel items).

    // Amount should inialize to zero (grade zero is for items where a grade could not be identified above)
    cDiscountedFuelAmount := POSRound(cMaxPrice * VolumeByGrade[0], 2);
    for j := 1 to MAX_GRADE_NUMBER do
    begin
      if (VolumeByGrade[j] > 0.0) then
      begin
        try
          cUnDiscountedPrice := cMaxPrice;
          Close();
          SQL.Clear();
          SQL.Add('select CashPrice from Grade where GradeNo = :pGradeNo');
          ParamByName('pGradeNo').AsInteger := j;
          Open();
          if (not EOF) then
            cUnDiscountedPrice := FieldByName('CashPrice').AsCurrency;
          Close();
          // Determine discounted price
          cDiscountedPrice := cUnDiscountedPrice;
          SQL.Clear();
          SQL.Add('select Amount from Disc where DiscNo = :pDiscNo and RecType = :pRecType');
          ParamByName('pDiscNo').AsInteger := CASH_EQUIV_FUEL_DISC_NO + j;
          ParamByname('pRecType').AsString := 'F';
          Open();
          if (not EOF) then
            cDiscountedPrice := cDiscountedPrice - FieldByName('Amount').AsCurrency;
        except
          cDiscountedPrice := cMaxPrice;
        end;
        cDiscountedFuelAmount := cDiscountedFuelAmount + POSRound(cDiscountedPrice * VolumeByGrade[j], 2);
      end;  // if (VolumeByGrade[j] > 0.0)
    end;  // for j := 0 to MAX_GRADE_NUMBER

    // Search for any fuel items that are priced incorrectly for the tender used.
//    if (cQualifyingAmount >= cDiscountedFuelAmount) then
//    begin
    for j := 0 to CurSaleList.Count - 1 do
    begin
      qSalesData := CurSaleList.Items[j];
      if ((qSalesData^.LineType = 'FUL') and (not qSalesData^.LineVoided) and (qSalesData^.SaleType = 'Sale')) then
      begin
        // Determine grade of fuel (from Fuel SaleID in sales list entry) and prices.
        iFuelGradeNo := 0;
        try
          // Determine the fuel grade.
          Close();
          SQL.Clear();
          SQL.Add('select Min(P.GradeNo) as FuelGradeNo from FuelTran F join PumpDef P');
          SQL.Add('  on F.PumpNo = P.PumpNo and F.HoseNo = P.HoseNo');
          SQL.Add('  where F.SaleID = :pSaleID');
          ParamByName('pSaleID').AsInteger := CurSaleData^.FuelSaleID;
          Open();
          if (not EOF) then
            iFuelGradeNo := FieldByName('FuelGradeNo').AsInteger;
          Close();

          // Determine un-discounted price
          cUnDiscountedPrice := 0.0;
          SQL.Clear();
          SQL.Add('select CashPrice from Grade where GradeNo = :pGradeNo');
          ParamByName('pGradeNo').AsInteger := iFuelGradeNo;
          Open();
          if (not EOF) then
            cUnDiscountedPrice := FieldByName('CashPrice').AsCurrency;
        except
          cUnDiscountedPrice := 0.0;
        end;
        Close();

        // Determine discounted price
        cDiscountedPrice := cUnDiscountedPrice;
        SQL.Clear();
        SQL.Add('select Amount from Disc where DiscNo = :pDiscNo and RecType = :pRecType');
        ParamByName('pDiscNo').AsInteger := CASH_EQUIV_FUEL_DISC_NO + iFuelGradeNo;
        ParamByname('pRecType').AsString := 'F';
        Open();
        if (not EOF) then
          cDiscountedPrice := cDiscountedPrice - FieldByName('Amount').AsCurrency;

        // If fuel item not properly priced (based on type of tender), then modify it.
        if (cQualifyingAmount >= cDiscountedFuelAmount) then
          cRequiredPrice := cDiscountedPrice                     // Tender qualifies for discount
        else
          cRequiredPrice := cUnDiscountedPrice;                  // Tender does not qualify for discount
        if ((qSalesData^.Price <> cRequiredPrice) and (cRequiredPrice > 0.0)) then
        begin
          cNewAmount := POSRound(qSalesData^.Qty * cRequiredPrice, 2);
//          cDiscountAmount := cNewAmount - qSalesData^.ExtPrice;
          if (cNewAmount > qSalesData^.ExtPrice) then
            i := fmPOSErrorMsg.YesNo('POS Confirm', 'Fuel Discount Does Not Apply For Payment Type.  Continue')
          else
            i := fmPOSErrorMsg.YesNo('POS Confirm', 'Fuel Discount Now Applies For Payment Type.  Continue';
//          if ((bPinPadActive > 0) and (DCOMPinPad <> nil)) then
//          begin
//            try
//              DCOMPinPad.SetPrompt(NOPINPADPROMPT_PLEASEWAIT);
//            except
//            end;
//          end;

          if ( i <> mrOk) then
          begin
            RetValue := False;
            break;
          end;
          qSalesData^.Price := cRequiredPrice;
          qSalesData^.ExtPrice := cNewAmount;
          if (j < POSListBox.Count) then
          begin
            POSListBox.ItemIndex := j;
            POSListBox.DeleteSelected();
            POSListBox.ItemIndex := j;
            DisplaySaleList(True);
          end;
          bFullCardTender := ((FuelCardType <> '') and (fmNBSCCForm.ChargeAmount = nCurAmountDue));  //20070615a
          PoleMdse();
          ComputeSaleTotal();        // Will recalculate nCurAmountDue
          POSListBox.Refresh;
          if (bFullCardTender) then                                             //20070615a
            fmNBSCCForm.ChargeAmount := nCurAmountDue;                          //20070615a
        end;
      end;  // if ((qSalesData^.LineType = 'FUL') ...
    end;  // for j := 0 to CurSaleList.Count - 1
//    end;   // if (cQualifyingAmount >= cDiscountedFuelAmount)
  end;  // with
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  AdjustFuelPriceForTender := RetValue;
end;  // procedure TfmPOS.AdjustFuelPriceForTender  // cCreditPrice

function TfmPOS.PaymentQualifiesForDiscountedFuelPrice(const FuelMediaNo : integer;
                                                       const FuelCardType : string) : boolean;
var
  RetVal : boolean;
begin
  if (Setup.DBVersionID >= DB_VERSION_ID_MEDIA_FUEL_DISCOUNT) then
  begin
    try
      if not POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close();
        SQL.Clear();
        if (FuelMediaNo in [CREDIT_MEDIA_NUMBER, DEBIT_MEDIA_NUMBER, EBT_FS_MEDIA_NUMBER, EBT_CB_MEDIA_NUMBER]) then
        begin
          SQL.Add('select * from ccvalidcards v join disc d on v.DiscNo = d.DiscNo where v.CardType = :pCardType and d.RecType = :pRecType and d.DiscNo = :pDiscNo');
          ParamByName('pCardType').AsString := FuelCardType;
        end
        else
        begin
          SQL.Add('select * from Media m join disc d on m.FuelDiscNo = d.DiscNo where m.MediaNo = :pMediaNo and d.RecType = :pRecType and d.DiscNo = :pDiscNo');
          ParamByName('pMediaNo').AsInteger := FuelMediaNo;
        end;
        ParamByName('pRecType').AsString := 'F';
        ParamByName('pDiscNo').AsInteger := CASH_EQUIV_FUEL_DISC_NO;
        Open();
        RetVal := ( not EOF);
        Close();
      end;  // with
      if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
    except
      RetVal := False;
      UpdateExceptLog('PaymentQualifiesForDiscountedFuelPrice - cannot access Media table');
    end;
  end
  else
  begin
    RetVal := ((FuelMediaNo in [CASH_MEDIA_NUMBER, DEBIT_MEDIA_NUMBER]) or (FuelCardType = CT_DEBIT));
  end;
  PaymentQualifiesForDiscountedFuelPrice := RetVal
end;  // function PaymentQualifiesForDiscountedFuelPrice

{$ENDIF}


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CheckCCBatch
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.CheckCCBatch;
begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('SELECT count(*) FROM CCBatch ');
    SQL.Add('WHERE (HostID > 0) and (Collected = 0) AND ');
    SQL.Add(' (EntryType <> :pEntryType) AND ');
    SQL.Add(      '((Cardtype = '''') or (Acctnumber = '''') or'                 );
    SQL.Add(      ' ((ExpDate = '''') and (CardType <> :pCardType)))'   );
    ParamByName('pEntryType').AsString := ENTRY_TYPE_BARCODE;
    ParamByName('pCardType').AsString := CT_GIFT;
    Open;
    if fieldbyname('count').AsInteger > 0 then
    begin
      { We found corrupted entries in the CCBatch table... }
      POSError('Bad Credit Card Entries found ! Please contact support ');
    end;
    Close;SQL.Clear;
    SQL.Add('SELECT count(*) FROM CCBatch ');
    SQL.Add('WHERE (Posted = 0) and (HostID > 0) and (HostID <> 5)');
    open;
    //if RecordCount > 0 then
    if (fieldbyname('count').AsInteger > 0) and (ThisTerminalNo = 1) then
    //Build 26
      POSError('Unposted Credit Card Entries found ! Please contact support ');
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisplayMenu
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: MenuNo : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.DisplayMenu(MenuNo : short );
var
KybdNdx, nBtnNo, nStartNo : short;
FoundIt : boolean;
begin
  nCCKey := 0;
  FoundIt := False;
  if MenuNo = 0 then
  begin
    //20070529a...
    // If returning from printing prior receipt, clear any receipt data.
    // (This is normally done when processing the key, but an exception could cause that logic to be skipped.)
    if (bPrintingPriorReceipt) then
    begin
      bPrintingPriorReceipt := False;
      curSale.nFSSubtotal := 0;
      curSale.nFuelSubtotal := 0;
      curSale.nSubtotal := 0;
      curSale.nTlTax := 0;
      curSale.bSalesTaxXcpt := False;
      curSale.nTotal := 0;
      curSale.nAmountDue := 0;
      curSale.nChangeDue := 0;
      curSale.nTransNo := 0;
      CurSalelist.Clear;
      CurSalelist.Capacity := CurSalelist.Count;
      POSListBox.Clear;
    end;
    //...20070529a
    KybdNdx := 0;
    FoundIt := True;
  end
  else
  begin
    for KybdNdx := 1 to 40 do
    begin
      if KybdArray[KybdNdx,0].MenuNo = MenuNo then
      begin
        FoundIt := True;
        break;
      end;
    end;
  end;
  if not FoundIt then
    KybdNdx := 0;

  if bFuelSystem then
    nStartNo := 4
  else
    nStartNo := 1;

  for nBtnNo := nStartNo to MaxKeyNo do
  begin
    DisplayTouchKeys( KybdNdx, nBtnNo ) ;
    if POSButtons[nBtnNo].KeyType = 'NMD' then
    begin
      nNextDollarKey := nBtnNo;
      SetNextDollarKeyCaption;
    end;
    if (POSButtons[nBtnNo].KeyType = 'MED') and (POSButtons[nBtnNo].KeyVal = sCreditMediaNo) then
    begin
      nCCKey := nBtnNo;
      UpdateCCKeyColor;
    end;
  end;
  //if KybdNdx = 0 then
  //  SetNextDollarKeyCaption;


end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisplayModifierMenu
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ModifierGroup : currency
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.DisplayModifierMenu(ModifierGroup : currency );
var
KeyNdx, KybdNdx, nBtnNo, nStartNo : short;
FoundIt : boolean;
begin
  FoundIt := False;
  nCurMenu := 99;
  for KybdNdx := 1 to 40 do
    begin
      if KybdArray[KybdNdx,0].MenuNo = nCurMenu then
        begin
          FoundIt := True;
          break;
        end;
    end;

  if not FoundIt then
    begin
      nCurMenu := 0;
      exit;
    end;

  if bFuelSystem then
    nStartNo := 4
  else
    nStartNo := 1;

  for KeyNdx := nStartNo - 1 to MaxKeyNo - 1  do
    begin
      KybdArray[KybdNdx,KeyNdx].KeyType            := '';
      KybdArray[KybdNdx,KeyNdx].KeyVal             := '';
      KybdArray[KybdNdx,KeyNdx].Preset             := '';
      KybdArray[KybdNdx,KeyNdx].KeyCaption         := '';
      KybdArray[KybdNdx,KeyNdx].BtnVisible := False;
    end;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      //20060713a...
//      SQL.Add('SELECT * from  MODIFIER WHERE ModifierGroup = ' + FloatToStr(ModifierGroup) + ' ORDER BY MODIFIERNO' );
      SQL.Add('SELECT * from  MODIFIER INNER JOIN PLUMOD ON ((PLUMOD.PLUModifierGroup = MODIFIER.ModifierGroup) AND (PLUMOD.PLUMODIFIER = MODIFIER.MODIFIERNO)) WHERE ModifierGroup = ' + FloatToStr(ModifierGroup) + ' ORDER BY MODIFIERNO' );
      //...20060713a
      Open;
      KeyNdx := nStartNo - 1;
      while not EOF do
        begin
          KybdArray[KybdNdx,KeyNdx].KeyType            := 'MOD';
          KybdArray[KybdNdx,KeyNdx].KeyVal             := FloatToStr(ModifierGroup);
          KybdArray[KybdNdx,KeyNdx].Preset             := IntToStr(FieldByName('ModifierNo').AsInteger);
          KybdArray[KybdNdx,KeyNdx].KeyCaption         := FieldByName('ModifierName').AsString;
          KybdArray[KybdNdx,KeyNdx].BtnVisible := True;
          Inc(KeyNdx);
          Next;
        end;
      close;
    end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  KybdArray[KybdNdx,KeyNdx].KeyType            := 'BPS';
  KybdArray[KybdNdx,KeyNdx].KeyVal             := '';
  KybdArray[KybdNdx,KeyNdx].Preset             := '';
  KybdArray[KybdNdx,KeyNdx].KeyCaption         := 'Clear';
  KybdArray[KybdNdx,KeyNdx].BtnVisible := True;

  for nBtnNo := nStartNo to MaxKeyNo do
    begin
      DisplayTouchKeys( KybdNdx, nBtnNo ) ;
    end;

  //20061204b
  MessageBeep(1);
//20061206a  if (fmPOS.bPlayWave) then
//20061206a    MakeNoise(RESPONSESOUND);
  //20061204b

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.SetNextDollarKeyCaption
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.SetNextDollarKeyCaption;
var
amt : currency;
begin
  //if nCurMenu > 0 then exit;

  if (nNextDollarKey > 0) and (POSButtons[nNextDollarKey].KeyType = 'NMD') then
  begin
    if (curSale.nTotal > 0) and (SaleState = ssSale )then
    begin
      amt := int(curSale.nTotal);
      if frac(curSale.nTotal) > 0 then
        amt := Amt + 1;
      POSButtons[nNextDollarKey].Caption := '$' + FloatToStr(amt);
      POSButtons[nNextDollarKey].Refresh;
    end
    else if (curSale.nAmountDue > 0) and (SaleState = ssTender )then
    begin
      amt := int(curSale.nAmountDue);
      if frac(curSale.nAmountDue) > 0 then
        amt := Amt + 1;
      POSButtons[nNextDollarKey].Caption := '$' + FloatToStr(amt);
      POSButtons[nNextDollarKey].Refresh;
    end
    else if (curSale.nAmountDue < 0) and (SaleState = ssTender) then
    with POSButtons[nNextDollarKey] do
    begin
      Caption := 'Balance Trans';
      Font.Size := 9;
      Refresh;
    end
    else
    with POSButtons[nNextDollarKey] do
    begin
      Caption := '';
      Font.Size := 14;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.POSButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.POSButtonClick(Sender: TObject);
begin
  if (Sender is TPOSTouchButton) then
    with TPOSTouchButton(Sender) do
      ProcessKey(KeyType, KeyVal, KeyPreset, MgrLock)
end;

//20070425a...
procedure TfmPOS.POSListBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Sender is TPOSListBox) then
  begin
    // If mouse pointing below all POS items, then change the focus to the display entry area
    // so the next USB scanner or keyboard entry will work.  (If on an entry, then let the
    // "on click" handler handle this; otherwise, the POS entry will not be selected.)
    if (Y > (fmPOS.POSListBox.Count * fmPOS.POSListBox.Count)) then
    begin
      try //20070509a
        fmPOS.DisplayEntry.SetFocus();
      except
      end;
    end;
  end;
end;
//...20070425a

//20070307a...
procedure TfmPOS.POSListBoxClick(Sender: TObject);
begin
  if (Sender is TPOSListBox) then
  begin
    try  //20070509a
      fmPOS.DisplayEntry.SetFocus();
    except
    end;
  end;
end;


procedure TfmPOS.eTotalClick(Sender: TObject);
begin
  if (Sender is TEdit) then
  begin
    fmPOS.DisplayEntry.SetFocus();
  end;
end;

//...20070307a

function TfmPOS.EnforceWindow(Value : TWinControl) : boolean;
begin
  Result := Value.Visible;
  if Result then
    if Value.Handle <> GetActiveWindow then
      SetActiveWindow(Value.Handle);
end;

function TfmPOS.EnforceWindows() : boolean;
begin
  Result := EnforceWindow(fmPOSErrorMsg) or
            EnforceWindow(fmPOSMsg) or
            EnforceWindow(fmNBSCCForm) or
            EnforceWindow(fmGiftForm) or
            EnforceWindow(fmFuelSelect) or
            EnforceWindow(fmPopUpMsg) or
            EnforceWindow(fmCWAccessForm) or
            EnforceWindow(fmPriceCheck) or
            EnforceWindow(fmPLUSalesReport) or
            EnforceWindow(fmValidAge) or
            EnforceWindow(fmEnterAge) or
            EnforceWindow(fmCardReceipt) or
            EnforceWindow(fmFuelReceipt) or
            EnforceWindow(fmUser) or
            EnforceWindow(fmPriceCheck) or
            EnforceWindow(fmPriceOverride);
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.FuelButtonClick
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.FuelButtonClick(Sender: TObject);
begin
  if EnforceWindows() then Exit;

  if Sender is TPumpxIcon then
  begin
    ProcessKeyPMP(IntToStr(TPumpxIcon(Sender).PumpNo), '');
    if assigned(Self.InjectionPort) and Self.InjectionPort.Open then
    try
      Self.InjectionPort.PutString(#02 + 'BTN' + #30 + 'PMP' + #30 + IntToStr(TPumpxIcon(Sender).PumpNo) + #03);
    except
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.InitScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.InitScreen();
begin
  // TODO: Add more of these to SaleHeader type
  if bSaleComplete then
    begin
      lbReturn.Visible := False;
      bSaleComplete := False;
    end;
  //20060714 Added to modify list font to non True Type for cleaner display on PCs
  {$IFDEF SALES_LIST_FONT_COURIER}
  POSListBox.Font.Name := 'Courier';
  {$ENDIF}

  //20070307a...
  POSListBox.OnClick := POSListBoxClick;
  POSListBox.OnMouseDown := POSListBoxMouseDown;  //20070425a
  eTotal.OnClick     := eTotalClick;
  //...20070307a

  bCCUsed := False;
  bDebitUsed := False;
  bOpenDrawer := False;
  SaleState := ssNoSale;

  If bClearListBox Then
    Begin
      lTotal.Caption := 'Total';
      eTotal.Text := '';
      eTotal.Visible := True;
      POSListBox.Clear;
      EmptyReceiptList;
      curSale.nTransNo := 0;
      StatusBar1.Panels.Items[1].Text := 'Trans#';
    End;

  curSale.nFuelSubtotal := 0;
  curSale.nFSSubtotal := 0;
  curSale.FoodStampMediaAmount := 0.0;
  curSale.FuelMediaAmount := 0.0;
  curSale.nSubtotal := 0;
  curSale.nTlTax := 0;
  curSale.bSalesTaxXcpt := False;
  curSale.nTotal := 0;
  //Gift
  curSale.nMedia := 0;
  //Gift
  curSale.nAmountDue := 0;
  curSale.nChangeDue := 0;
  nCustBDay := 0;
  nBeforeDate := 0;
  nModifierValue := 0;
  nModifierName := '';
  curSale.bSalesTaxXcpt := False;
  curSale.nNonTaxable := 0;
  curSale.nDiscountableTl := 0;
  KioskOrderNo := 0;
  POSListBox.Refresh;
  SetNextDollarKeyCaption;

end;



{-----------------------------------------------------------------------------
  Name:      TfmPOS.CheckKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TWMPOSKey
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.CheckKey(var Msg:TWMPOSKey);
var
FirstOne,LastOne : PChar;
sKey : string;
begin
 KeyBuff[BuffPtr] := Msg.KeyCode;

 If Error_SkipKey Then
  Begin
    Error_SkipKey := False;
    KeyBuff := '';
    BuffPtr := 0;
    Exit;
  End;

 if (KeyBuff[0] = '%') and (SaleState <> ssNoSale) then  {Magstripe indicator Track 1}
   begin
     FirstOne := StrScan(KeyBuff,#7);
     if FirstOne > nil then
       begin
         KeyBuff := '';
         BuffPtr := 0;
       end;

     Track2Timer.Enabled := false;
     Track2Timer.Enabled := True;

     FirstOne := StrScan(KeyBuff,'?');
     if FirstOne > nil then
       begin

       LastOne := StrRScan(KeyBuff,'?');
       if LastOne > FirstOne then
         begin
           EntryBuff := '';
           StrCopy(EntryBuff,KeyBuff);
           KeyBuff := '';
           BuffPtr := 0;
           Track2Timer.Enabled := False;
           PostMessage(fmPOS.Handle,WM_PREPROCESSKEY,0,0);
           Exit;
         end;

       end;

   end
 else if (KeyBuff[0] = ';') and (SaleState <> ssNoSale) then   {Magstripe indicator Track 2}
   begin
     Track2Timer.Enabled := False;

     FirstOne := StrScan(KeyBuff,#7);
     if FirstOne > nil then
       begin
         KeyBuff := '';
         BuffPtr := 0;
       end;

     FirstOne := StrScan(KeyBuff,'?');
     if FirstOne > nil then
       begin
         EntryBuff := '';
         StrCopy(EntryBuff,KeyBuff);
         KeyBuff := '';
         BuffPtr := 0;
         PostMessage(fmPOS.Handle,WM_PREPROCESSKEY,0,0);
         Exit;
       end;
   end
 else if KeyBuff[0] = 'Z' then         {UPC indicator}
   begin
   if KeyBuff[BuffPtr] = #13 then      // Strip Off 'Z' And Format as PLU Key
     begin
       sEntry := Copy(KeyBuff,2,(BuffPtr-1));
       StrPCopy(KeyBuff, sPLUKeyCode);
       StrCopy(EntryBuff,KeyBuff);
       KeyBuff := '';
       BuffPtr := 0;
       PostMessage(fmPOS.Handle,WM_PREPROCESSKEY,0,0);
       Exit;
     end
   end
 else if BuffPtr = 1 then                {Normal POS Keys}
   begin
      sKey := Uppercase(KeyBuff[0]);
      StrCopy(EntryBuff,KeyBuff);
      KeyBuff := '';
      BuffPtr := 0;
      If (sKey[1] in ['A'..'N']) Then
        Begin
          PostMessage(fmPOS.Handle,WM_PREPROCESSKEY,0,0);
        End
      else
        Begin
          Error_SkipKey := True;
        End;
      Exit;
   end;
 if KeyBuff[BuffPtr] <> #13 then
   Inc(BuffPtr,1);

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.KillPOS
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TMessage
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.KillPOS(var Msg: TMessage);
begin



//  SendFuelMessage(1, PMP_IDLE, 0);

  while (bPostingSale or bPostingCATSale or bPostingPrePaySale)  do
    begin
      application.processmessages;
      sleep(20);
    end;

  bPOSForceClose := True;
  Close;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PreProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.PreProcessKey(var Msg:TMessage);
var
  sKeyChar: string[2];
  CheckMSR : string;
begin
  {$IFDEF CAT_SIMULATION}
  if ((bCATSimulation) and ((CATSimulationTrack1 <> '') or (CATSimulationTrack2 <> ''))) then
  begin
    CATSimulationFuelMsg := '';
    CATSimulationFuelMsg  := BuildTag(FSTAG_PUMPNO, '0') +
                             BuildTag(FSTAG_PUMPACTION, IntToStr(PMP_CAT_SIMULATE_MSR)) +
                             BuildTag(CRTAG_TRACK1DATA, CATSimulationTrack1) +
                             BuildTag(CRTAG_TRACK2DATA, CATSimulationTrack2);
    case nFuelInterfaceType of
      1, 2 : DCOMFuelProg.SendMsg('POSSrvr', ThisTerminalNo, CATSimulationFuelMsg);
    end;
    CATSimulationTrack1 := '';
    CATSimulationTrack2 := '';
  end;
  {$ENDIF}

  
  Track2Timer.Enabled := False;

  if ( fmPOSErrorMsg.Tag = POS_ERROR_MSG_TAG_CARD_ACTIVATION) then
  begin
    ClearCardActivationPrompt();
  end;
  // Only the first swipe after scanning an activation product is accepted.
  if (ActivationProductData.bNextSwipeForProduct) then
  begin
    ActivationProductData.bNextSwipeForProduct := False;
    ActivationProductData.bThisSwipeForProduct := True;
  end
  else
  begin
    ClearActivationProductData(@ActivationProductData);
  end;
  if fmPOSErrorMsg.Visible or
    fmPOSMsg.Visible or
    fmFuelSelect.Visible or
    fmPLUSalesReport.Visible or
    fmValidAge.Visible or
    fmEnterAge.Visible or
    fmNBSCCForm.Visible or
    fmGiftForm.Visible or
    fmCWAccessForm.Visible or
    fmCardReceipt.Visible or
    fmFuelReceipt.Visible or
    fmPopUpMsg.Visible or
    fmPriceOverride.visible or
    fmPriceCheck.visible or
    fmUser.Visible Then
    exit;

  Self.InjLog('TfmPOS.PreProcessKey - ' + EntryBuff);
  if (EntryBuff[0] = '%') or (EntryBuff[0] = ';') then   // MagStrip Indicator
  begin
    UpdateZLog('TfmPOS.PreProcessKey - MagStripe Detected');
    //Gift
    // Verify that a gift card is not being used to purchase a gift card.

    CheckMSR := EntryBuff;
    if ((POS('=', CheckMSR) <= 0) and (POS('?', CheckMSR) > 0) and (POS('B', CheckMSR) <= 0)) then
    begin
      // MSR data has gift card format.  See if any gift cards are to be activated.
      if (GiftCardTotal() > 0.0) then
      begin
        PosError('Cannot use gift card to activate a gift card.');
        exit;
      end;
    end;
    // See if swipe is for non-tender activation type product
    // Verify OK to process card media types (or balance inquiries with ssNoSale).
    if ((SaleState <> ssNoSale)) then
    begin
      ProcessKey('MED', sCreditMediaNo, '', False);
    end;
  end
  else if (EntryBuff[0] = 'X') then   // MagStrip Indicator
  begin
    POSError('Bad Card Read - Please Enter Manually' );
    ProcessKey('MED', sCreditMediaNo, '', False);
  end
  else if (EntryBuff[0] = #02) then // Injection
  begin
    ProcessKey(ParseString(EntryBuff,2,#30),ParseString(EntryBuff,3,#30),'',False);
  end
  else if msg.WParam <> 0 then
  begin
    UpdateZLog('Preprocesskey %d, %d', [msg.WParam, msg.LParam]);
    case msg.WParam of
      LU_RET_BAR :  ProcessKeyBAR(TResumeKeyMode(msg.LParam));
      LU_RET_ASU :  ProcessKeyASU(TResumeKeyMode(msg.LParam));
      LU_RET_EOD :  ProcessKeyEOD(TResumeKeyMode(msg.LParam));
      LU_RET_EOS :  ProcessKeyEOS(TResumeKeyMode(msg.LParam));
      SYNCHRONIZE_PKMED : ProcessKeyMED('MED', IntToStr(CREDIT_MEDIA_NUMBER), '', False);
    end;
  end
  else                         // Regular KeyCode
  begin
    // Get KeyCode (2 chars) array
    sKeyChar := UpperCase(Copy(EntryBuff,1,2));
    if (sKeyChar[1] in ['A'..'N']) and (sKeyChar[2] in ['1'..'8']) then
    begin
      ProcessKey(KBDef[sKeyChar[1], sKeyChar[2]].KeyType, KBDef[sKeyChar[1], sKeyChar[2]].KeyVal, KBDef[sKeyChar[1], sKeyChar[2]].Preset, False);
    end;
  end;
end;

procedure TfmPOS.MSRPortDataEvent(const Value : String);
var
  track1data, track2data : string;
  scp : integer;
{$IFDEF CAT_SIMULATION}
  CharPosition : integer;
  r1           : integer;
{$ENDIF}
begin
  if length(Value) = 0 then
    exit;
  Move(Value[1], EntryBuff[0], length(Value)); EntryBuff[length(Value)] := #0;
{$IFDEF CAT_SIMULATION}
  if (bCATSimulation) then
  begin
    CATSimulationTrack1 := '';
    CATSimulationTrack2 := '';

    r1 := Length(EntryBuff);
    CharPosition := Pos(';',EntryBuff);
    if (CharPosition > 0) then
    begin
      CATSimulationTrack1 := Copy(EntryBuff, 1, CharPosition-1);
      CATSimulationTrack2 := Copy(EntryBuff, CharPosition , r1-CharPosition+1 );
    end
    else
    begin
      CATSimulationTrack2 := EntryBuff;
    end;
    PostMessage(fmPOS.Handle,WM_PREPROCESSKEY,0,0);
    exit;
  end;
{$ENDIF}
  if (CreditHostReal(nCreditAuthType)) then
  begin
    if Pos('%',Value)  > 0 then
      Track1Data := Copy(Value,Pos('%',Value), Pos('?',Value));
    scp := Pos(';',Value);
    if scp > 0 then
      Track2Data := Copy(Value, scp , PosEX('?', Value, scp) - scp + 1);
    QueryValidCard(VC_MSRSWIPE, Track1data, Track2data, '', '', '');
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ScannerPortTriggerAvail
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CP: TObject; Count: Word
  Result:    None
  Purpose:
-----------------------------------------------------------------------------} {
procedure TfmPOS.ScannerPortTriggerAvail(CP: TObject; Count: Word);
var
  i           : word;
  c           : char;
begin
  for i := 1 to count do
  begin
    c :=  ScannerPort.GetChar;
    if c = STX then
    begin
      BuffPtr := 0;
      KeyBuff := '';
      bScanStarted := True;
    end
    else if (c = ETX)  then
      ScannerPortDataEvent()
    else if (c = ' ') then
    begin
      symbology := Copy(KeyBuff,0,BuffPtr);
      BuffPtr := 0;
      KeyBuff := '';
    end
    else
    begin
      KeyBuff[BuffPtr] := c;
      Inc(BuffPtr);
    end;
  end;
end;                                                                            }

function TfmPOS.LicenseValidate(instr : String; sym : string) : Boolean;
var
  dbsym : string;
  p : integer;
begin
  try
    dbsym := Config.Str['SCAN_ID_SYMBOLOGY'];
  except
    dbsym := 'Code39|Code128';
  end;
  LicenseValidate := False;
  p := Pos(sym, dbsym);
  if (p = 0) then
    POSError('License Barcode incorrect type: ' + sym);
  if (p <> 0) and (  (Length(instr) = 17) or
          ((Length(instr) = 18) and (ord(instr[1]) >= 65) and (ord(instr[1]) <= 90)) ) then
  begin
    try
      if StrToInt64(RightStr(instr,17)) > 0 then
        LicenseValidate := True
    except
      UpdateExceptLog('TfmPOS.LicenseValidate: StrToInt64 failed on: ' + RightStr(instr,17));
    end;
  end;
end;

function TfmPOS.LicenseDateParse(instr : String) : TDateTime;
var
  scandatestr : string;
begin
  scandatestr := RightStr(instr,8);
  LicenseDateParse := EncodeDate(StrToInt(RightStr(scandatestr, 4)),
                                 StrToInt(LeftStr(scandatestr, 2)),
                                 StrToInt(MidStr(scandatestr, 3, 2)));
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ScannerPortDataEvent
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ScannerPortDataEvent(const Sym: String; const BarCode: String);
var
  TempInt     : integer;
  PriceVerification : boolean;
  ModifierGroup : Currency;
  ndx : Byte;
  DataOut : pScannedPLU;
  KSLDataOut : pScannedKSL;
begin
  if fmPOSErrorMsg.visible and (fmPOSErrorMsg.tag <> POS_ERROR_MSG_TAG_CARD_ACTIVATION) then
  begin
    if fmPOSErrorMsg.Active = False then
      //fmPOSErrorMsg.SetFocus;
      SetActiveWindow(fmPOSErrorMsg.Handle);
    PostMessage(fmPOSErrorMsg.Handle, WM_CHECKKEY, 0, 0);
    exit;
  end
  else if fmKiosk.Visible then
  begin
    SetActiveWindow(fmKiosk.Handle);
    sEntry := '';
    if (SaleState  = ssNoSale) and (not fmValidAge.Visible) and (not fmPriceCheck.Visible)
       and (not fmPriceOverride.Visible) and (not fmEnterAge.Visible) then
      InitScreen;
    sEntry := Copy(KeyBuff,2,(BuffPtr - 1));
    //20060922a        TempInt := strtoint(copy(sEntry,2,length(sEntry)-2));
    //20060922a        sEntry := inttostr(TempInt);
    fmKiosk.fldKioskCode.Text := sEntry;
    sEntry := '';
    fmKiosk.Visible := False;
  end
   else if (Pos(',',barcode) > 1) then
    begin
      //sEntry := sCopy(OPOSScanner.ScanData, 1, (Length(OPOSSCanner.ScanData) - 1));
     // Showmessage('From Scaner DataEvent');
     UpdateZLog('From Scaner DataEvent-tarang');
      ProcessTdBarCode(barcode);
    end

  else if (fmMOLoad <> nil) and fmMOLoad.Visible then
  begin
    fmMOLoad.ProcessScan(Sym, BarCode);
  end

  else if (fmMOInq <> nil) and fmMOInq.Visible then
  begin
    fmMOInq.ProcessScan(Sym, BarCode);
  end

  else if (MoDocEntry <> nil) and MoDocEntry.Visible then
  begin
    MoDocEntry.ProcessScan(Sym, Barcode);
  end

  else if fmInventoryInOut.visible then
    fmInventoryInOut.ProcessScan(BarCode)

  else if fmValidAge.Visible and LicenseValidate(BarCode, Sym) then
  begin
    try
      nCustBDay := LicenseDateParse(BarCode);
      if CustAgeOK(fmValidAge.AgeRestriction) then
        fmValidAge.btnOKClick(fmValidAge)
      else
      begin
        fmValidAge.btnNOClick(fmValidAge);
        POSError('The Customer is NOT Old Enough to Purchase this Item');
      end;
    except
      fmValidAge.btnNOClick(fmValidAge);
      POSError('Invalid date entry "' + BarCode + '"');
    end;
  end

  else if (not (nCurMenu = 99)) and (fmUser.Visible = False) then
  begin
    PriceVerification := false;
    EntryBuff := '';
    sEntry := barcode;

    if (length(sEntry) <> 13) or
         (((Copy(sEntry,1,1) <> '8') and (Copy(sEntry,1,1) <> '9')) and (length(sEntry) = 13)) then
    begin
      StrPCopy(KeyBuff, sPLUKeyCode);
      StrCopy(EntryBuff,KeyBuff);
      KeyBuff := '';
      BuffPtr := 0;
      //?sKeyType := 'PLU';
      //?sKeyVal  := '';
      //?sPreset  := '';
        try
          nNumber := StrToFloat(sEntry);
        except
          nNumber := 0;
        end;
      if (SaleState  = ssNoSale) and (not fmValidAge.Visible) and (not fmPriceCheck.Visible)
         and (not fmPriceOverride.Visible) and (not fmEnterAge.Visible) then
        InitScreen;
      if fmValidAge.Visible then
      begin
        if fmValidAge.Active = False then
          //fmValidAge.SetFocus;
          SetActiveWindow(fmValidAge.Handle);
        PostMessage(fmValidAge.Handle, WM_CHECKKEY, 0, 0);
      end
      else if fmEnterAge.Visible then
      begin
        if fmEnterAge.Active = False then
          //fmEnterAge.SetFocus;
          SetActiveWindow(fmEnterAge.Handle);
        PostMessage(fmEnterAge.Handle, WM_CHECKKEY, 0, 0);
      end
      else if fmPriceOverride.Visible then
      begin
        if fmPriceOverride.active = false then
          //fmPriceoverride.setfocus;
          SetActiveWindow(fmPriceOverride.Handle);
        PostMessage(fmPriceOverride.Handle,WM_CHECKKEY,0,0);
      end
      else if fmPriceCheck.Visible then
      begin
        if fmPriceCheck.Active = False then
          //fmPriceCheck.SetFocus;
          SetActiveWindow(fmPriceCheck.Handle);
        PostMessage(fmPriceCheck.Handle,WM_CHECKKEY,0,0);
        try
          nNumber := StrToFloat(sEntry);
        except
          nNumber := 0;
        end;
        if not POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.StartTransaction;
        with POSDataMod.IBPLUQuery do
        begin
          Close;SQL.Clear;
          //20070213a...
          //              SQL.Add('Select * from PLU where PLUNo = :pNumber or UPC = :pUPC');
          SQL.Add('Select * from PLU where (PLUNo = :pNumber or UPC = :pUPC) and (DelFlag = 0 or DelFlag is null)');
          //...20070213a
          ParamByName('pNumber').AsCurrency := nNumber;
          ParamByName('pUPC').AsCurrency    := nNumber;
          Open;
          fmPriceCheck.Label1.Caption := 'Item Desctiption';
          if recordcount > 0 then
          begin
            ModifierGroup := FieldByName('ModifierGroup').AsCurrency;
            if ModifierGroup > 0 then
            begin
              with POSDataMod.IBTempQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add('SELECT * from  MODIFIER WHERE ModifierGroup = ' + FloatToStr(ModifierGroup) + ' ORDER BY MODIFIERNO' );
                Open;
                ndx := 1;
                fmPriceCheck.fldPrice.value := 0.00;
                fmPriceCheck.fldDescription.text := '';
                fmPriceCheck.Label1.Caption := POSDataMod.IBPLUQuery.fieldbyname('Name').AsString;
                while not eof do
                begin
                  fmPriceCheck.BuildKeyPad(1,ndx,ndx);
                  Inc(Ndx);
                  Next;
                end;
                close;
              end;
            end
            else
            begin
              fmPriceCheck.fldDescription.Text := fieldbyname('Name').AsString;
              fmPriceCheck.fldPrice.value := fieldbyname('Price').AsCurrency;
            end;
          end
          else
          begin
            fmPriceCheck.fldDescription.Text := 'Not Found';
            fmPriceCheck.fldPrice.value := 0.00;
          end;
          close;
        end;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        //?sKeyType := '';
        sEntry   := '';
        sPLUKeyCode := '';
      end
      else
        if (not PriceVerification) and (SaleState  <> ssTender) then
        begin
          New(DataOut);
          DataOut^.PLU := nNumber;
          DataOut^.KeyType := 'PLU';
          PostMessage(fmPOS.Handle,WM_SCANNED_PLU,longint(DataOut),0);//ProcessKey;
        end;
    end
    else if (Copy(sEntry,1,1) = '9') and (length(sEntry) = 13) then
    begin
      KeyBuff := '';
      BuffPtr := 0;
      //?sKeyType := 'XMD';//Cross Merchandise Discount on Fuel
      //?sKeyVal  := '';
      //?sPreset  := '';
      sEntry := copy(sEntry,1,length(sEntry)-1);
      if SaleState  <> ssTender then
      begin
        New(DataOut);
        DataOut^.PLU := strtofloat(sEntry);
        DataOut^.KeyType := 'XMD';
        PostMessage(fmPOS.Handle,WM_SCANNED_PLU,longint(DataOut),0);
      end;
      //ProcessKey;
    end
    else if (Copy(sEntry,1,1) = '8') and (length(sEntry) = 13) then
    begin
      //?sKeyVal  := '';
      KeyBuff := '';
      BuffPtr := 0;
      //?sPreset  := '';
      if (SaleState  = ssNoSale) and (not fmValidAge.Visible) and (not fmPriceCheck.Visible)
         and (not fmPriceOverride.Visible) and (not fmEnterAge.Visible) then
        InitScreen;
      TempInt := strtoint(copy(sEntry,2,length(sEntry)-2));
      sEntry := inttostr(TempInt);
      New(KSLDataOut);
      KSLDataOut^.KSL := sEntry;
      PostMessage(fmPOS.Handle,WM_SCANNED_KSL,longint(KSLDataOut),0);
      //ProcessKeyKSL;
    end

      (*StrPCopy(KeyBuff, sEntry);
        sPLUKeyCode := sEntry;
        StrCopy(EntryBuff,KeyBuff);

        KeyBuff := '';
        BuffPtr := 0;
        sKeyType := 'PLU';
        sKeyVal  := '';
        sPreset  := '';
        bETXReceived := True;*)
  end
    //ProcessKey;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.OPOSScannerDataEvent
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; Status: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.OPOSScannerDataEvent(Sender: TObject; Status: Integer);
var
  PriceVerification : boolean;
  ModifierGroup : Currency;
  ndx : Byte;
  TempInt : Integer;
begin
  if (fmPOSErrorMsg.visible and ( fmPOSErrorMsg.Tag <> POS_ERROR_MSG_TAG_CARD_ACTIVATION)) then
  begin
    OPOSScanner.DataEventEnabled := True;
    if fmPOSErrorMsg.Active = False then
      fmPOSErrorMsg.SetFocus;
    PostMessage(fmPOSErrorMsg.Handle, WM_CHECKKEY, 0, 0);
    exit;
  end
  else if fmKiosk.Visible then
  begin
    if (SaleState  = ssNoSale) and (not fmValidAge.Visible) and (not fmPriceCheck.Visible)
       and (not fmPriceOverride.Visible) and (not fmEnterAge.Visible) then
      InitScreen;
    //20060922a...
    //    TempInt := strtoint(Copy(OPOSScanner.ScanData,3,length(OPOSSCanner.ScanData) - 2));
    //    sEntry := IntToStr(TempInt);
    sEntry := Copy(OPOSScanner.ScanData,2,length(OPOSSCanner.ScanData) - 1);
    //...20060922a
    fmKiosk.fldKioskCode.Text := sEntry;
    sEntry := '';
    fmKiosk.Visible := False;
  end
    //inv2...
  else if fmInventoryInOut.visible then
  begin
    sEntry := '';
    sEntry := Copy(OPOSScanner.ScanData, 2, (Length(OPOSSCanner.ScanData) - 1));
    fmInventoryInOut.ProcessScan(sEntry);
  end
    //...inv2
    {$IFDEF INSIDE_2D_SCAN}  //20070103a...
                             //Scan 2d barcode for age validation
  else if fmEnterAge.Visible then
  begin
    if copy(OPOSScanner.ScanData,1,2) = 'A@' then
    begin
      if Pos('DBB',OPOSScanner.ScanData) > 0 then
        EnterAge.DateEntry := Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+7,2) +
          Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+9,2) +
          Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+5,2);
      EnterAge.DateDisplay := Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+7,2) + '/' +
        Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+9,2) + '/' +
        Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+3,4);
      fmEnterAge.Edit1.Text := EnterAge.DateDisplay;
    end;
  end
  else if fmValidAge.Visible then
  begin
    if copy(OPOSScanner.ScanData,1,2) = 'A@' then
    begin
      if Pos('DBB',OPOSScanner.ScanData) > 0 then
        GetAge.EntDate := StrtoDate(Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+7,2) + '/' +
                                      Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+9,2) + '/' +
                                      Copy(OPOSScanner.ScanData,Pos('DBB',OPOSScanner.ScanData)+3,4));
      DecodeDate(Date, Year, Month, Day);
      Year := Year - fmValidAge.AgeRestriction;
      if (Month = 2) and (Day = 29) then
        Day := 28;
      nBeforeDate := EncodeDate(Year, Month,Day);
      if GetAge.EntDate <= nBeforeDate then
        fmValidAge.btnOKClick(fmValidAge)
      else
      begin
        fmValidAge.btnNOClick(fmValidAge);
        POSError('The Customer is NOT Old Enough to Purchase this Item');
      end;
    end;
  end
    {$ENDIF}  //...20070103a
  else if (not (nCurMenu = 99)) and (fmUser.Visible = False) then
  begin
    PriceVerification := false;
    EntryBuff := '';
    sEntry := Copy(OPOSScanner.ScanData,2,length(OPOSSCanner.ScanData) - 1);
    //XMD
    if Copy(OPOSSCanner.ScanData,1,1) = 'A' then
    begin
      StrPCopy(KeyBuff, sPLUKeyCode);
      StrCopy(EntryBuff,KeyBuff);
      KeyBuff := '';
      BuffPtr := 0;
      //?sKeyType := 'PLU';
      //?sKeyVal  := '';
      //?sPreset  := '';
      if (SaleState  = ssNoSale) and (not fmValidAge.Visible) and (not fmPriceCheck.Visible)
         and (not fmPriceOverride.Visible) and (not fmEnterAge.Visible) then
        InitScreen;
      if fmValidAge.Visible then
      begin
        if fmValidAge.Active = False then
          fmValidAge.SetFocus;
        PostMessage(fmValidAge.Handle, WM_CHECKKEY, 0, 0);
      end
      else if fmEnterAge.Visible then
      begin
        if fmEnterAge.Active = False then
          fmEnterAge.SetFocus;
        PostMessage(fmEnterAge.Handle, WM_CHECKKEY, 0, 0);
      end
      else if fmPriceOverride.Visible then
      begin
        if fmPriceOverride.active = false then
          fmPriceoverride.setfocus;
        PostMessage(fmPriceOverride.Handle,WM_CHECKKEY,0,0);
      end
      else if fmPriceCheck.Visible then
      begin
        if fmPriceCheck.Active = False then
          fmPriceCheck.SetFocus;
        PostMessage(fmPriceCheck.Handle,WM_CHECKKEY,0,0);
        try
          nNumber := StrToFloat(sEntry);
        except
          nNumber := 0;
        end;
        if not POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.StartTransaction;
        with POSDataMod.IBPLUQuery do
        begin
          Close;SQL.Clear;
          //20070213a...
          //          SQL.Add('Select * from PLU where PLUNo = :pNumber or UPC = :pUPC');
          SQL.Add('Select * from PLU where (PLUNo = :pNumber or UPC = :pUPC) and (DelFlag = 0 or DelFlag is null)');
          //...20070213a
          ParamByName('pNumber').AsCurrency := nNumber;
          ParamByName('pUPC').AsCurrency    := nNumber;
          Open;
          fmPriceCheck.Label1.Caption := 'Item Desctiption';
          if recordcount > 0 then
          begin
            ModifierGroup := FieldByName('ModifierGroup').AsCurrency;
            if ModifierGroup > 0 then
            begin
              with POSDataMod.IBTempQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add('SELECT * from  MODIFIER WHERE ModifierGroup = ' + FloatToStr(ModifierGroup) + ' ORDER BY MODIFIERNO' );
                Open;
                ndx := 1;
                fmPriceCheck.fldPrice.value := 0.00;
                fmPriceCheck.fldDescription.text := '';
                fmPriceCheck.Label1.Caption := POSDataMod.IBPLUQuery.fieldbyname('Name').AsString;
                while not eof do
                begin
                  fmPriceCheck.BuildKeyPad(1,ndx,ndx);
                  Inc(Ndx);
                  Next;
                end;
                close;
              end;
            end
            else
            begin
              fmPriceCheck.fldDescription.Text := fieldbyname('Name').AsString;
              fmPriceCheck.fldPrice.value := fieldbyname('Price').AsCurrency;
            end;
          end
          else
          begin
            fmPriceCheck.fldDescription.Text := 'Not Found';
            fmPriceCheck.fldPrice.value := 0.00;
          end;
          close;
        end;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        //?sKeyType := '';
        //?sEntry   := '';
        sPLUKeyCode := '';
      end
      else
        if (not PriceVerification) and (SaleState  <> ssTender) then
          ProcessKey('PLU','','',False);
    end
    else if Copy(OPOSSCanner.ScanData,1,2) = 'F9' then
    begin
      KeyBuff := '';
      BuffPtr := 0;
      sEntry := Copy(OPOSScanner.ScanData,2,length(OPOSSCanner.ScanData) - 1);
      if SaleState  <> ssTender then
        ProcessKey('XMD','','',False);
    end
    else if Copy(OPOSSCanner.ScanData,1,2) = 'F8' then
    begin
      if Length(OPOSSCanner.ScanData) < 14 then
        TempInt := strtoint(Copy(OPOSScanner.ScanData,3,length(OPOSSCanner.ScanData) - 2))
      else
        TempInt := strtoint(Copy(OPOSScanner.ScanData,3,length(OPOSSCanner.ScanData) - 3));
      //sKeyVal  := '';
      KeyBuff := '';
      BuffPtr := 0;
      //sPreset  := '';
      if (SaleState  = ssNoSale) and (not fmValidAge.Visible) and (not fmPriceCheck.Visible)
         and (not fmPriceOverride.Visible) and (not fmEnterAge.Visible) then
        InitScreen;
      sEntry := IntToStr(TempInt);
      ProcessKeyKSL;
    end
  end;
  OPOSScanner.DataEventEnabled := True;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKey(const sKeyType : string; const sKeyVal : string; const sPreset : string; const bMgrLock : boolean);
var
  tmpndx : short;
  bForceExit : boolean;
  MyHandle         : Hwnd;
  HandleLoopCount  : Integer;
  TmpStr           : String;
  TmpPChar         : Array [0..100] of char;
  SysmgrHandle     : Hwnd;
  bAllowed         : boolean;
  bForceLoad       : boolean;  //20070405b
  OrigType, OrigVal : string;
begin
    UpdateZLog('inside ProcessKey function and key type -tarang');
 //  ShowMessage('inside ProcessKey function and key type :'+sKeyType);  // madhu   remove
  // sKeyType := 'PPR';   // MADHU GV 27-10-2017   CHECK
  if not ((fmPOSErrorMsg.Handle = GetActiveWindow) and (fmPOSErrorMsg.Caption = 'Card Activation')) then
    if EnforceWindows() then Exit;
  OrigType := sKeyType;
  OrigVal := sKeyVal;
   UpdateZLog(Format('ProcessKey :tarang  sKeyType="%s", sKeyVal="%s"',[sKeyType,sKeyVal]));
  Self.InjLog(Format('ProcessKey sKeyType="%s", sKeyVal="%s"',[sKeyType,sKeyVal]));
  bForceExit := False;

  bScanStarted := False;
  if sKeyType = 'PMP' then   {Pump Number}
  begin
    ProcessKeyPMP(sKeyVal, sPreset);
    bForceExit := True;
  end
  else if sKeyType = 'PAT' then   {Pump Authorize}
  begin
    ProcessKeyPAT;
    bForceExit := True;
  end
  else if sKeyType = 'PST' then   {Pump Preset}
  begin
    ProcessKeyPST;
    bForceExit := True;
  end
  else if sKeyType = 'PAL' then   {Pump Authorize}
  begin
    ProcessKeyPAL;
    bForceExit := True;
  end
  else if sKeyType = 'PLR' then    { Print Last Receipt }
  begin
    ProcessKeyPLR;
    bForceExit := True;
  end
  else if (sKeyType = 'PFL')  and NOT (PRINT_OLD_RECEIPT) then    { Print Last Fuel Only Receipt }
  begin
    ProcessKeyPFL;
    bForceExit := True;
  end
  else if sKeyType = 'MOD' then
  begin
    ProcessKeyMOD(sKeyVal);
    if bNeedModifier then
    begin
      //FIXME sKeyType := 'PLU';       //force post ring of PLU
      bNeedModifier := False;
    end
    else
      bForceExit := True;
  end;

  if bForceExit then
  begin
    if assigned(Self.InjectionPort) and Self.InjectionPort.Open then
    try
      Self.InjectionPort.PutString(#02 + 'BTN' + #30 + OrigType + #30 + OrigVal + #03);
    except
    end;
    Exit;
  end;

  If PRINT_OLD_RECEIPT Then
   Begin
     { We are printing an old Receipt so send the keystrokes there}
     DisplayReceipts(sKeyType);
     Exit;
   End;

  if (CreditHostAllowsTotals(nCreditAuthType) and
               (SaleState = ssNoSale) and (sKeyType = 'MED') and (sKeyVal = sCreditMediaNo)) then
    begin
    end
  else if (SaleState = ssNoSale) then
    begin
      //PDO
      //if (sKeyType = 'MED') or (sKeyType = 'NMD') then
      if (sKeyType = 'MED') or (sKeyType = 'NMD') or (sKeyType = 'PDO') then
        exit;
    end;

  if bSaleComplete then
    InitScreen();


  if bSkipOneKey then
    bSkipOneKey := False
  else
    sPumpNo := '';

  nTimercount := 0;

  if bMgrLock and NOT(bAllowMgrLock) then
    begin
      POSError('Mgr Access Required');
      exit;
    end;

  //********************************************************************
  //*                                                                  *
  //*        allow these keys regardless of register state             *
  //*                                                                  *
  //********************************************************************

  if sKeyType = 'NUM' then
     ProcessKeyNUM(sKeyVal)
  else if sKeyType = 'CLR' then
  begin
    ClearEntryField;
    if (lbReturn.Visible = True) and (SaleState = ssNoSale) then
         lbReturn.Visible := False;
  end
  else if sKeyType = 'BPS' then
  begin
    if (nCurMenu > 0) then
    begin
      nCurMenu := 0;
      DisplayMenu(nCurMenu);
      bCaptureNFPLU := False;
      bNeedModifier := False;
      ClearEntryField;
    end;
  end
  else if sKeyType = 'UP ' then
     ProcessKeyUP
  else if sKeyType = 'DN ' then
     ProcessKeyDN
  else if sKeyType = 'PMP' then   {Pump Number}
     ProcessKeyPMP(sKeyVal, sPreset)
  else if sKeyType = 'PRS' then   {Pump Resume}
     ProcessKeyPRS
  else if sKeyType = 'PHL' then   {Pump Halt}
     ProcessKeyPHL
  else if sKeyType = 'EHL' then   {Emergency Pump Halt}
     ProcessKeyEHL
  else if sKeyType = 'PDA' then   {Pump DeAuth}
     ProcessKeyPDA
  else if sKeyType = 'PRT' then   {Printer Reset}
     ProcessKeyPRT
  else if sKeyType = 'CAT' then   {Restart CAT Server}
    begin
       ProcessKeyCAT;
       LogCATReset('Full CAT Reset');
    end
  else if sKeyType = 'CT1' then   {Single CAT Soft Reset}
    begin
       ProcessKeyCT1;
       LogCATReset('Single CAT Soft Reset #'+sPumpNo);
    end
  else if sKeyType = 'CT2' then   {Single CAT Hard Reset}
    begin
       ProcessKeyCT2;
       LogCATReset('Single CAT Hard Reset #'+sPumpNo);
    end
  else if sKeyType = 'CT3' then   {Single CAT OnOffLine}
    begin
       ProcessKeyCT3;
       LogCATReset('Single CAT On/Offline #'+sPumpNo);
    end
  else if sKeyType = 'CDT' then   {Restart Credit Server}
    begin
      fmPOSMsg.ShowMsg('Resetting Credit Server...',' ');                       //20070717a
      ProcessKeyCDT;
      LogCreditReset;
      Sleep(300);                                                               //20070717a
      fmPOSMsg.Close;                                                           //20070717a
    end
  else if sKeyType = 'FUL' then   {Fuel Server Reset}
    begin
      ProcessKeyFUL;
      LogFuelReset;
    end
  else if sKeyType = 'PRF' then   {Pump Refresh}
    begin
      ProcessKeyPRF;
      LogPumpRefresh(sPumpNo);
    end
  else if sKeyType = 'CRL' then    { Controller Reload }
       ProcessKeyCRL
  else if sKeyType = 'SCR' then
        ProcessKeySCR
  else if sKeyType = 'MNU' then
    begin
      ProcessKeyMNU(sKeyVal);
      Exit;
    end
  else if sKeyType = 'POR' then
  begin;
    ProcessKeyPOR;
    Exit;
  end
  else if sKeyType = 'CKN' then
    ProcessKeyCKN
  else if sKeyType = 'CLK' then
    ProcessKeyCLK
  else if sKeyType = 'PRC' then
    ProcessPriceCheck
  else if sKeyType = 'CWR' then
    ProcessKeyCWR;

  UpdateZLog('Sale State: %s, sKeyType: %s', [SaleStateStr(SaleState), sKeyType]);
  //Build 38
  if SaleState in [ssNoSale, ssBankFunc] then//SaleState = ssNoSale then
  begin
    if sKeyType = 'NSL' then
      ProcessKeyNSL
    else if sKeyType = 'IPL' then    //Import Factor PLU
    begin
      fmPOS.Timer1.Enabled := False;  //20071018b
      fmPOS.PopUpMsgTimer.Enabled := False;  //20071018b
      bForceLoad := false;  // Initail assumption  //20070405b   //20070515d (value changed to false)
      if (Setup.EODExport = 2) or (Setup.EOSExport = 2) then
      begin
        ImportFactorPLU;
        bForceLoad := true;   //20070515d
      end
      else if (Setup.EODExport = 3) or (Setup.EOSExport = 3) then
      begin
        ImportPDIPLU;
        bForceLoad := true;   //20070515d
      end
      else if (Setup.EODExport = 5) or (Setup.EOSExport = 5) then
      begin
        try
          ImportSysMgrPLU();
          ActivatePLUImport();
          ActivateDeptImport();
          {$IFDEF FF_PROMO}
          ActivateSysMgrFuelFirstPromo();
          {$ENDIF}
          bForceLoad := true;
        finally
          if fmPOSMsg.Visible then
            fmPOSMsg.Close();                                                      //20071005b
        end
      end;

      //20071018b...Update Kiosk prices if Kiosk is active
      if bKioskActive then
        UpdateKioskPrices();   //20071107f
      //...20071018b

      if (bForceLoad) then  //20070405b
      begin
        if not POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.StartTransaction;
        with POSDataMod.IBTempQuery do
        begin
          Close;SQL.Clear;
          SQL.Add('Update Terminal Set ReloadSetup = 1' );
          try
            ExecSQL;
          except
          end;
        end;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        ProcesskeyUSO;                   // Force load of updated PLUs after import  //20060911a
        PopUpMsgTimer.Enabled := True;                                               //20060911a
      end;  // if (bForceLoad)
      fmPOS.Timer1.Enabled := True;  //20071018b
      fmPOS.PopUpMsgTimer.Enabled := True;  //20071018b
    end
    //20070405b...
    else if sKeyType = 'AIM' then    //Activate Import
    begin
      //20070515d...
//      if (Setup.EODExport = 5) or (Setup.EOSExport = 5) then
//      begin
//        ActivatePLUImport();
//        {$IFDEF FF_PROMO}
//        ActivateSysMgrFuelFirstPromo();
//        {$ENDIF}
//        if not POSDataMod.IBTransaction.InTransaction then
//          POSDataMod.IBTransaction.StartTransaction;
//        with POSDataMod.IBTempQuery do
//        begin
//          Close;SQL.Clear;
//          SQL.Add('Update Terminal Set ReloadSetup = 1' );
//          try
//            ExecSQL;
//          except
//          end;
//        end;
//        if POSDataMod.IBTransaction.InTransaction then
//          POSDataMod.IBTransaction.Commit;
//        ProcesskeyUSO;                   // Force load of updated PLUs after import  //20060911a
//        PopUpMsgTimer.Enabled := True;                                               //20060911a
//      end;  // if (Setup.EODExport = 5) or (Setup.EOSExport = 5)
      POSError('Function now combined with Import PLU (IPL) button');
      //...20070515d
    end
    //...20070405b
    else if sKeyType = 'USO' then    { User Sign on / off }
    begin
      if bSuspendedSale then
        POSError('Complete Suspended Sale Before Logging Off !')
      else
        ProcessKeyUSO;
    end
    else if sKeyType = 'BAR' then    { BackupAndRestore }
      ProcessKeyBAR(mResumeKeyInit)
    else if sKeyType = 'ASU' then    { Apply Software Update }
      ProcessKeyASU(mResumeKeyInit)
    else if sKeyType = 'CLS' then
    begin
      if fmPOSErrorMsg.YesNo('POS Confirm', 'Close POS') = mrOk then
        Close;
    end
    else if sKeyType = 'SP1' then    {Send Fuel Prices }
      ProcessKeySP1
    else if sKeyType = 'CFP' then    {Change Fuel Prices }
    begin
      if SkipPassCheck then
        ProcessKeyCFP
      else
      begin
        if not POSDataMod.IBDb.TestConnected then
          fmPOS.OpenTables(False);
        if not POSDataMod.IBUserTransaction.InTransaction then
          POSDataMod.IBUserTransaction.StartTransaction;
        POSDataMod.IBUserQuery.Open;
        bAllowed := Boolean(POSDataMod.IBUserQuery.FieldByName('POSFUELPRICE').AsInteger);
        POSDataMod.IBUserQuery.Close;
        if POSDataMod.IBUserTransaction.InTransaction then
          POSDataMod.IBUserTransaction.Commit;
        if bAllowed then
          ProcessKeyCFP
        else
          POSError('Function Not Allowed For UserID');
      end;
    end

    else if (sKeyType >= 'RP1') and (sKeyType <= 'RPZ') then   {Reports}
      ProcessReport(sKeyType)
    else if sKeyType = 'EOS' then    { End of Shift }
    begin
      if SkipPassCheck then
        ProcessKeyEOS(mResumeKeyInit)
      else
      begin
        if not POSDataMod.IBUserTransaction.InTransaction then
          POSDataMod.IBUserTransaction.StartTransaction;
        POSDataMod.IBUserQuery.Open;
        bAllowed := Boolean(POSDataMod.IBUserQuery.FieldByName('POSEOS').AsInteger);
        POSDataMod.IBUserQuery.Close;
        if POSDataMod.IBUserTransaction.InTransaction then
          POSDataMod.IBUserTransaction.Commit;
        if bAllowed then
          ProcessKeyEOS(mResumeKeyInit)
        else
          POSError('Function Not Allowed For UserID');
      end;
    end
    else if sKeyType = 'EOD' then    { End of Day }
    begin
      if ThisTerminalNo = MasterTerminalNo then
      begin
        if SkipPassCheck then
          ProcessKeyEOD(mResumeKeyInit)
        else
        begin
          if not POSDataMod.IBUserTransaction.InTransaction then
            POSDataMod.IBUserTransaction.StartTransaction;
          POSDataMod.IBUserQuery.Open;
          bAllowed := Boolean(POSDataMod.IBUserQuery.FieldByName('POSEOD').AsInteger);
          POSDataMod.IBUserQuery.Close;
          if POSDataMod.IBUserTransaction.InTransaction then
            POSDataMod.IBUserTransaction.Commit;
          // bAllowed := TRUE; // MADHU
          if bAllowed then
            ProcessKeyEOD(mResumeKeyInit)
          else
            POSError('Function Not Allowed For UserID');
        end;
      end
      else
        POSError('Please Close Day on Terminal 1');

    end
    else if sKeyType = 'REC' then    { Print Receipt }
      ProcessKeyREC
    else if sKeyType = 'CCR' then    { Print Credit Card Receipt }
      ProcessKeyCCR
    else if sKeyType = 'PFR' then    { Print Fuel Receipt }
      ProcessKeyPFR
    else if sKeyType = 'BNK' then    { BankFunction }
      ProcessKeyBNK(sKeyVal)
    else if sKeyType = 'VST' then    { View Store - All }
      ProcessReport(sKeyType)
    else if sKeyType = 'VPL' then    { View PLU - All }
      ProcessReport(sKeyType)
    else if sKeyType = 'VHR' then    { View Hourly - All }
      ProcessReport(sKeyType)
    else if sKeyType = 'VEJ' then    { View Electronic Journal }
      ProcessReport(sKeyType)
    else if sKeyType = 'RTN' then    { Return / Manager Void}
    begin
      if SkipPassCheck then
        lbReturn.Visible := True
      else
      begin
        if not POSDataMod.IBUserTransaction.InTransaction then
          POSDataMod.IBUserTransaction.StartTransaction;
        POSDataMod.IBUserQuery.Open;
        bAllowed := Boolean(POSDataMod.IBUserQuery.FieldByName('POSReturn').AsInteger);
        POSDataMod.IBUserQuery.Close;
        if POSDataMod.IBUserTransaction.InTransaction then
          POSDataMod.IBUserTransaction.Commit;
        if bAllowed then
          lbReturn.Visible := True
        else
          POSError('Function Not Allowed For UserID');
      end;
    end
    else if sKeyType = 'LSM' then    { Load System Manager }
    begin
      HandleLoopCount := 0;
      SysmgrHandle := 0;
      MyHandle := GetWindow (Application.Handle, GW_HWNDFIRST);
      Repeat
        GetClassName(MyHandle, TmpPChar, 100);
        TmpStr := StrPas(TmpPChar);
        If (TmpStr = 'TfmMainPOSBO') Then SysmgrHandle := MyHandle;
        MyHandle := GetWindow (MyHandle, GW_HWNDNEXT);
        Inc(HandleLoopCount);
      Until HandleLoopCount >100;

      If (SysmgrHandle <> 0) Then
      Begin
        SetForeGroundWindow(SysmgrHandle);
      end
      else
      begin
        if SkipPassCheck then
          ShellExecute(Handle,'open','SysMgr.exe', PChar(CurrentUserID),  PChar(ExtractFileDir(Application.ExeName)) ,sw_show)
        else
        begin
          if not POSDataMod.IBUserTransaction.InTransaction then
            POSDataMod.IBUserTransaction.StartTransaction;
          POSDataMod.IBUserQuery.Open;
          bAllowed := Boolean(POSDataMod.IBUserQuery.FieldByName('POSSysMgr').AsInteger);
          POSDataMod.IBUserQuery.Close;
          if POSDataMod.IBUserTransaction.InTransaction then
            POSDataMod.IBUserTransaction.Commit;
          if bAllowed then
            ShellExecute(Handle,'open','SysMgr.exe', PChar(CurrentUserID),  PChar(ExtractFileDir(Application.ExeName)) ,sw_show)
          else
            POSError('Function Not Allowed For UserID');
        end;
      end;

    end;

  end
  else
  begin

    if (sKeyType = 'NSL') or
       (sKeyType = 'CLS') or
       (sKeyType = 'SP1') or
       (sKeyType = 'CFP') or
       ((sKeyType >= 'RP1') and (sKeyType <= 'RPZ')) or
       (sKeyType = 'EOS') or
       (sKeyType = 'EOD') or
       (sKeyType = 'REC') or
       (sKeyType = 'CCR') or
       (sKeyType = 'PFR') or
       (sKeyType = 'BNK') or
       (sKeyType = 'VSA') or
       (sKeyType = 'VPA') or
       (sKeyType = 'VSS') or
       (sKeyType = 'VPS') or
       (sKeyType = 'VEJ') or
       (sKeyType = 'RTN') or
       (sKeyType = 'LSM') then
          POSError('Finish This Sale First!');

  end;
  //nTotalCheckCount := 1;
  if (nTotalCheckCount = 0) and not ((sKeyType = 'EOD') or (sKeyType = 'EOS')) then
  begin
    POSError('Rerun EOD/EOS First!');
    exit;
  end;

  if (SaleState in [ssNoSale, ssSale, ssTender]) then
  begin
    if sKeyType = 'SR ' then
      ProcessKeySR
    //Mega Suspend
    else if sKeyType = 'SR2' then
      ProcessKeySR2
    else if sKeyType = 'ERC' then
      ProcessKeyERC
    else if sKeyType = 'PBL' then
      ProcessKeyPBL
    //Mega Suspend
    else if (SaleState = ssTender) then
      begin
        ;  // No other key allows sale to be tendering.
      end
  //...bpj
    else if sKeyType = 'DPT' then
      ProcessKeyDPT(sKeyVal, sPreset)
    else if sKeyType = 'MOA' then
      ProcessKeyMOA()
    else if sKeyType = 'MOI' then
      ProcessKeyMOI()
    else if sKeyType = 'MOP' then
      ProcessKeyMOP()
    else if sKeyType = 'MOL' then
      ProcessKeyMOL()
    else if sKeyType = 'MOR' then
      ProcessKeyMOR()
    else if (sKeyType = 'PLU') or
            (sKeyType = 'MOD') then
    begin
      ProcessKeyPLU(sKeyVal, sPreset);
      if bCaptureNFPLU or bNeedModifier then
        exit;
    end
    else if ((sKeyType = 'ENT') and (sEntry <> '')) then
      ProcessKeyPLU(sEntry,'')
    else if sKeyType = 'PSL' then   {Pump Sale}
      ProcessKeyPSL
    else if sKeyType = 'PPR' then   {Pin Pad Reset}
      ProcessKeyPPR
    else if sKeyType = 'PPY' then   {Pump Prepay}
      ProcessKeyPPY
    else if sKeyType = 'COP' then   {Change On Pump}
      ProcessKeyCOP
    else if sKeyType = 'PPL' then
    begin
      ProcessKeyPLU(sKeyVal, sPreset);
      if bCaptureNFPLU or bNeedModifier then
         exit;
    end
    else if sKeyType = 'QTY' then
      ProcessKeyQTY
    //cwa...
    else if sKeyType = 'CWH' then
      ProcessKeyCWH()             // Car Wash
    //...cwa
    else if sKeyType = 'GFT' then
      ProcessKeyGFT
    //Kiosk
    else if sKeyType = 'KSL' then
      ProcessKeyKSL
    //Kiosk
    else if sKeyType = 'INV' then
      ProcessKeyInv;
  end;

  if (SaleState = ssSale) then
  begin
    if sKeyType = 'DSC' then
      ProcessKeyDSC(sKeyVal)
    {$IFDEF FUEL_PRICE_ROLLBACK}
    else if sKeyType = 'AFD' then  // Alter Fuel Discount
      ProcessKeyAFD
    {$ENDIF}
    else if sKeyType = 'TAX' then
      ProcessKeyTAX;
  end;

  if (SaleState in [ssSale, ssBankFunc]) then
  begin
    if sKeyType = 'CNL' then
      ProcessKeyCNL;
  end;

  if (SaleState = ssNoSale) then
  begin
    if ((sKeyType = 'MED') and (sKeyVal = sCreditMediaNo)) then
    begin
       // (todo) - may also want to ensure that MSR swipe did not cause PreProcessKey to call ProcessKey.
       //          may not be a problem because WM_PREPROCESSKEY is not posted when SaleState is ssNOSale.
      if (CreditHostAllowsTotals(nCreditAuthType))
                    {$IFDEF CATSIMULATION}
                    and (not bCATSimulation)
                    {$ENDIF} then
      begin
        ProcessCardTotals();
      end;
    end;
  end
  else  // i.e., SaleState <> ssNoSale
  begin
    if ((sKeyType = 'MED') or (sKeyType = 'XCT')) then
      ProcessKeyMED(sKeyType, sKeyVal, sPreset, False)
    else if (sKeyType = 'NMD') then
    begin
      if curSale.nAmountDue < 0 then
        BalanceOverTender
      else
        ProcessKeyMED(sKeyType, sKeyVal, sPreset, False);
    end
    //PDO
    else if sKeyType = 'PDO' then
      ProcessKeyPDO;
  end;

  if sKeyType <> 'NUM' then
  begin
    nModifierValue := 0;
    nModifierName := '';
  end;

  if (nCurMenu > 0) then
  begin
    for TmpNdx := 1 to 40 do
    begin
      if KybdArray[TmpNdx,0].MenuNo = nCurMenu then
      begin
        break;
      end;
    end;
    if KybdArray[TmpNdx,0].AutoMenuClose then
    begin
      if not ((sKeyType = 'NUM') or (sKeyType = 'CLR') or (sKeyType = 'QTY')) then
      begin
        nCurMenu := 0;
        DisplayMenu(nCurMenu);
        bCaptureNFPLU := False;
        bNeedModifier := False;
      end;
    end;
  end;

  //if (sKeyType <> 'COP') then  //20061023b
  //  sKeyVal := '';      //needed to clear last key value and accept plu with enter key  //20060828b

  if assigned(Self.InjectionPort) and Self.InjectionPort.Open then
  try
    if OrigType <> 'PPY' then
      Self.InjectionPort.PutString(#02 + 'BTN' + #30 + OrigType + #30 + OrigVal + #03);
  except
  end;

end; {procedure ProcessKey}


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessReport(const sKeyType : string);
var
ViewOK : boolean;
RptTerminalNo, RptShiftNo : integer;
begin

  RptTerminalNo := 0;
  RptShiftNo := 0;

  if SaleState = ssNoSale then
    begin
      LAST_REPORT := True;

      if (sKeyType = 'RP1') or
         (sKeyType = 'RP2') or
//         (sKeyType = 'RP3') or
         (sKeyType = 'RP4') or
         (sKeyType = 'RP5') or
         (sKeyType = 'RP6') or
         (sKeyType = 'RPS') or
         (sKeyType = 'VST') or
         (sKeyType = 'VPL') or
         (sKeyType = 'VHR') then
        begin
          if fmSelectTermShift.ShowModal <> mrOk then
            exit;
          RptTerminalNo := fmSelectTermShift.SelTerminal;
          RptShiftNo    := fmSelectTermShift.SelShift;
        end;

      if sKeyType = 'RP1' then         // Daily Sales
        begin
          PrintDailyReport (0, RptTerminalNo, RptShiftNo);
          PostSalesRptExec(ThisTerminalNo, nShiftNo);
        end
      else if sKeyType = 'RP2' then    // Hourly Sales
        begin
          HourlyReport(0, RptTerminalNo, RptShiftNo)
        end
      else if sKeyType = 'RP3' then    // PLU Sales
        begin
          fmPLUSalesReport.Visible := False;
          try
            If Not(fmPLUSalesReport.Visible) Then fmPLUSalesReport.ShowModal;
            fmPLUSalesReport.ModalResult := mrOK;
            fmPLUSalesReport.Visible := False;
          except
            fmPLUSalesReport.ModalResult := mrOK;
            sleep(100);
          end;
        end
      else if sKeyType = 'RP4' then    // Media Sales
        begin
          MediaSalesReport (0, RptTerminalNo, RptShiftNo, ConsolidateShifts);
          AssignTransNo;
          rcptSale.nTransNo := curSale.nTransNo;
          nRcptShiftNo := nShiftNo;
          PrintSeq;
          LogRpt('Manual Media Sales Report');
        end
      else if sKeyType = 'RP5' then    // Category Sales
        begin
          CategorySalesReport (0, RptTerminalNo, RptShiftNo, ConsolidateShifts);
          AssignTransNo;
          rcptSale.nTransNo := curSale.nTransNo;
          nRcptShiftNo := nShiftNo;
          PrintSeq;
          LogRpt('Manual Department Sales Report');
        end
      else if sKeyType = 'RP6' then    // Group Sales
        begin
          GroupSalesReport (0, RptTerminalNo, RptShiftNo, ConsolidateShifts);
          AssignTransNo;
          rcptSale.nTransNo := curSale.nTransNo;
          nRcptShiftNo := nShiftNo;
          PrintSeq;
          LogRpt('Manual Group Sales Report');
        end
      else if sKeyType = 'RP7' then    // Fuel Totals
        begin
//          {$IFDEF DEV_TEST}
//          CreateSnowBirdExportFile(0, 0, CurrentUser);
//          {$ELSE}
          FuelTotalsReport(False);
//          {$ENDIF}
        end
      else if sKeyType = 'RPA' then    // Batch Report
        begin
          CreditReport(0, 0);
        end
      else if sKeyType = 'RPB' then    // PDL Report
        begin
          CreditSetup;
        end
      else if sKeyType = 'RPC' then    // PLU List
        begin
          PLUList;
        end
      else if sKeyType = 'RPD' then    // Pump Off Line
        begin
          ProcessKeyRPD;
        end
      else if sKeyType = 'RPE' then    // Pump On Line
        begin
          ProcessKeyRPE;
        end
      else if sKeyType = 'RPF' then    // Force All Auth
        begin
          ProcessKeyRPF;
        end
      else if sKeyType = 'RPS' then    // Hourly Sales
        begin
          HourlySnoopReport(0, RptTerminalNo, RptShiftNo, ConsolidateShifts);
          PrintSeq;
        end
      else if sKeyType[1] = 'V' then
        begin
          if SkipPassCheck then
            ViewOK := True
          else
            begin
              if not POSDataMod.IBUserTransaction.InTransaction then
                POSDataMod.IBUserTransaction.StartTransaction;
              POSDataMod.IBUserQuery.Open;
              ViewOK := Boolean(POSDataMod.IBUserQuery.FieldByName('POSViewReport').AsInteger);
              POSDataMod.IBUserQuery.Close;
              if POSDataMod.IBUserTransaction.InTransaction then
                POSDataMod.IBUserTransaction.Commit;
            end;

          if ViewOK then
            begin
              if sKeyType = 'VST' then
                begin
                  fmViewReport.nViewReportType := 1;
                end
              else if sKeyType = 'VPL' then
                begin
                  fmViewReport.nViewReportType := 2;
                end
              else if sKeyType = 'VHR' then
                begin
                  fmViewReport.nViewReportType := 3;
                end
              else if sKeyType = 'VEJ' then
                begin
                  fmViewReport.nViewReportType := 5;
                end;
              fmViewReport.nTerminalNo := RptTerminalNo;
              fmViewReport.nShiftNo := RptShiftNo;
              fmViewReport.Visible := False;
              try
                If Not(fmViewReport.Visible) Then fmViewReport.ShowModal;
                fmViewReport.ModalResult := mrOK;
                fmViewReport.Visible := False;
              except
                fmViewReport.ModalResult := mrOK;
                sleep(100);
              end;
            end
          else
            POSError('Function Not Allowed For UserID');
        end;
    end
  else
    POSError('Report not Allowed in Sales Mode');

end; {procedure ProcessReport}


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessPriceCheck
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessPriceCheck();
begin
  fmPriceCheck.Show;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PrintDailyReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Terminal, Shift : Integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.PrintDailyReport (DayId, Terminal, Shift : Integer);
var
  RptCount, TlCount, X : integer;
  terminals : array of integer;
  intrans : boolean;
{-----------------------------------------------------------------------------
  Name:      DoReports
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: T, S : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
  procedure DoReports(d, T, S : integer);
  begin

     PRINTING_REPORT := True;
     Reports.PRINT_ALL := True;
     DailySalesReport(d, T, S, ConsolidateShifts);
     GroupSalesReport(d, T, S, ConsolidateShifts);
     CategorySalesReport(d, T, S, ConsolidateShifts);
     MediaSalesReport(d, T, S, ConsolidateShifts);
     BankSalesReport(d, T, S, ConsolidateShifts);
     Reports.PRINT_ALL := False;

     ReportFtr;
     AssignTransNo;
     rcptSale.nTransNo := curSale.nTransNo;
     nRcptShiftNo := nShiftNo;
     POSPrt.PrintSeq;
     LogRpt('Daily Sales Report');
     PRINTING_REPORT := False;


  end;

Begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;
  if Shift = 0 then
  begin
    DoReports(DayId, 0,0);
  end
  else if ((Terminal = 0) and (Shift > 0)) then
  begin
    with POSDataMod.IBRptSQL02Main do
    begin
      Assert(not open, 'IBRptSQL02Main is open');
      SQL.Text := 'select count(distinct(terminalno)) from totals';
      ExecQuery;
      setlength(terminals, Fields[0].AsInteger);
      Close;
      Assert(not open, 'IBRptSQL02Main is open');
      SQL.Text := 'Select Distinct(TerminalNo) from Totals order by TerminalNo';
      ExecQuery;
      x := 0;
      while not EOF do
      begin
        terminals[x] := Fields[0].AsInteger;
        next;
      end;
      Close;
    end;
    RptCount := 0;
    for x := 0 to Pred(length(terminals)) do
    begin
      with POSDataMod.IBRptSQL02Main do
      begin
        Assert(not open, 'IBRptSQL02Main is open');
        SQL.Text := 'Select Count(*) from Totals WHERE TerminalNo = :pTerminalNo and ShiftNo = :pShiftNo';
        ParamByName('pTerminalNo').AsInteger := terminals[x];
        ParamByName('pShiftNo').AsInteger := shift;
        ExecQuery;
        TlCount := Fields[0].AsInteger;
        Close;
      end;  // with
      if TlCount > 0 then
      begin
        DoReports(DayId, terminals[x], Shift);
        Inc(RptCount);
      end;
    end;  // for terminals
    if RptCount > 1 then
      DoReports(DayId, 0, Shift);
  end  // else if ((Terminal = 0) and (Shift > 0))
  else   // only used from eod - print report for passed terminal and shift
         // allows eod to clear any unclosed shifts before closing the day
  begin
    DoReports(DayId, Terminal, Shift);
  end;
  if not intrans then
    POSDataMod.IBRptTrans.Commit;

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FuelTotalsReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Reprint : boolean
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.FuelTotalsReport(Reprint : boolean);
var
  bReportAvail, bClosePOSMsg: Boolean;
  i : short;
  intrans : boolean;
Begin
  intrans := POSDataMod.IBRptTrans.InTransaction;
  if not intrans then
    POSDataMod.IBRptTrans.StartTransaction;

  bReportAvail := False;
  try
    i := Setup.FuelInterfaceType;
  except
    i := 1;
  end;
  if (i < 1) or (i > 2) then
    i := 1;

  case i of
  1,2 :   bReportAvail := True;  //1 - Simulator     2 - Progressive
  end;

  if NOT bReportAvail then
    exit;

  PRINTING_REPORT := True;
  if Setup.MeterReport = 1 then
  begin
    if NOT Reprint then
    begin
      SendFuelMessage( 0, FS_READTOTALS, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);
      fFuelTotals := True;
      nFuelTotalID := 0;
      bClosePOSMsg := Not(fmPOSMsg.Visible);
      fmPOSMsg.ShowMsg('', 'Requesting Fuel Totals...');
      while fFuelTotals = True do
        Application.ProcessMessages;
      if bClosePOSMsg then
        fmPOSMsg.Close;
      if EODInProgress then
      begin
        with POSDataMod.IBRptSQL02Main do
        begin
          Assert(not open, 'IBRptSQL02Main is open');
          SQL.Text := 'Update Totals Set PrevPumpTlID = CurPumpTlID Where TotalNo = 0';
          ExecQuery;
          Close;
          SQL.Text := 'Update Totals Set CurPumpTlID = :pCurPumpTlID Where TotalNo = 0';
          ParamByName('pCurPumpTlID').AsInteger := nFuelTotalID;
          ExecQuery;
          Close;
        end;
      end;
    end;
    if nFuelTotalID > 0 then
    begin
      PrintFuelMeterReport(0);
      {$IFNDEF PDI_PROMOS}
      PrintDiscTotals(0, 0, 0, True, ConsolidateShifts);
      {$ENDIF}
      AssignTransNo;
      rcptSale.nTransNo := curSale.nTransNo;
      nRcptShiftNo := nShiftNo;
      POSPrt.PrintSeq;
      LogRpt('Fuel Meter Report');
    end;
  end
  else
  begin
    PrintFuelTotalsReport(0);
    {$IFNDEF PDI_PROMOS}
    PrintDiscTotals(0, 0, 0, True, ConsolidateShifts);
    {$ENDIF}
    AssignTransNo;
    rcptSale.nTransNo := curSale.nTransNo;
    nRcptShiftNo := nShiftNo;
    POSPrt.PrintSeq;
    LogRpt('Fuel Totals Report');
  end;
  PRINTING_REPORT := False;
  if not intrans then
    POSDataMod.IBRptTrans.Commit;

End;




{-----------------------------------------------------------------------------
  Name:      TfmPOS.CreditReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ShiftNo : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.CreditReport(DayId, ShiftNo : integer);
var
  bClosePOSMsg: Boolean;
  StartTime : TDateTime ;
  nStartBatch, nEndBatch : integer;
  CCMsg : string;
  GiftCount : integer;
  GiftAmount : Currency;
  //sdd...
  GiftCountNBS : integer;
  GiftAmountNBS : currency;
  GiftCountOther : integer;
  GiftAmountOther : currency;
  //...sdd
begin
//cwe  GiftCount := 0;
//cwe  GiftAmount := 0;
  //ada...
//  if nCreditAuthType < 2 then
  if (not (CreditHostReal(nCreditAuthType))) then
  //...ada
    exit;

  PRINTING_REPORT := True;
  bClosePOSMsg := Not(fmPOSMsg.Visible);

  if NOT (EODInProgress or EOSInProgress) then
    begin
      fmPOSMsg.ShowMsg('Balancing Credit Sales...', '');

      fCreditTotals := True;
      nCreditBatchID := 0;
      nCreditBatchPDL := 0;
      //Build 16
      //CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_CLOSEBATCH));
      CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_CLOSEBATCH)) +
               BuildTag(TAG_EOD_IN_PROGRESS, IntToStr(Integer(DAYCLOSEInProgress)));
      //Build 16
      SendCreditMessage(CCMsg);
    end;

  StartTime := Now();

  while fCreditTotals = True do
    begin
      Application.ProcessMessages;
      sleep(200);
      if TimerExpired(StartTime, 45) then  //20070511c  (value changed from 180 to 45 seconds)
      begin
        fCreditTotals := False;
        UpdateExceptLog('Warning - EOD Credit sales timer expired instead of being notified by CreditServer');
      end
      else
        fmPOSMsg.ShowMsg('', 'Waiting for credit sales to balance - ' + IntToStr(45 - SecondsBetween(Now(),StartTime)));
    end;

  if NOT (EODInProgress or EOSInProgress) then
    fmPOSMsg.ShowMsg('Printing Credit Sales...', '');

  // Get Starting Batch for Shift / Day
  if DayId = 0 then
    with POSDataMod.IBTempQuery do
    begin
      Transaction.StartTransaction;
      DayID := POSDataMod.GetDayId(Transaction);
      Transaction.Commit;
    end;
  if ShiftNo > 0 then
    ReportHdr('Batch Credit Report - EOS')
  else
    ReportHdr('Batch Credit Report - EOD');

  // Print Batch Report for Each Batch in CCRTB
  if not POSDataMod.IBBatchReportTransaction.InTransaction then
    POSDataMod.IBBatchReportTransaction.StartTransaction;
  with POSDataMod.IBBatchReportQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('SELECT * FROM CCRTB');
    SQL.Add('ORDER By BATCHID');
    Open;
    while Not EOF do
    begin
      if (Dayid = FieldByName('DayID').AsInteger) or
        not Boolean(FieldByName('Balanced').AsInteger) then
          CCBatchReport(FieldByName('BatchID').AsInteger,
                        FieldByName('DayID').AsInteger,
                        DayID,
                        FieldByName('OpenDate').AsDateTime,
                        Boolean(FieldByName('Balanced').AsInteger)  );
      Next;
    end;
    Close;
  end;
  if POSDataMod.IBBatchReportTransaction.InTransaction then
    POSDataMod.IBBatchReportTransaction.Commit;
  // Totals By Card Type
  nStartBatch := 0;
  nEndBatch   := 0;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add( 'Select Min(BatchID) StartBatch, Max(BatchID) EndBatch FROM CCRTB');
    SQL.Add( 'Where DayID = :pDayID');
    ParamByName('pDayID').AsInteger := DayID;
    Open;
    if NOT Eof then
    begin
      nStartBatch := FieldByName('StartBatch').AsInteger;
      nEndBatch   := FieldByName('EndBatch').AsInteger;
    end;
    Close;SQL.Clear;
    //bpe...
//    if nCreditAuthType = 2 then
//      SQL.Add('Select Count(*) as cnt, sum(Amount/100) as amt from CCBatch where ')
//    else
    //...bpe (todo) (split dial) next where clause may be NBS specific.
    SQL.Add('Select Count(*) as cnt, sum(Amount) as amt from CCBatch where ');
    //sdd...
//    SQL.Add('BatchID > :pMin and BatchID < :pMax and (NBSTranCode = :pAct or NBSTranCode = :pRec)');
    SQL.Add('HostID = :pHostID and BatchID > :pMin and BatchID < :pMax and (NBSTranCode = :pAct or NBSTranCode = :pRec)');
    //...sdd
    parambyname('pHostID').AsInteger := CDTSRV_NBS;
    parambyname('pMin').AsString := inttostr(nStartBatch - 1);
    parambyname('pMax').AsString := inttostr(nEndBatch + 1);
    parambyname('pAct').AsString := TC_ACTIVATE;
    parambyname('pRec').AsString := TC_RECHARGE;
    open;
    if fieldbyname('Cnt').asInteger > 0 then
    begin
      //sdd...
//      GiftCount := fieldbyname('Cnt').asInteger;
//      GiftAmount := fieldbyname('amt').AsCurrency;
      GiftCountNBS := fieldbyname('Cnt').asInteger;
      GiftAmountNBS := fieldbyname('amt').AsCurrency;
      //...sdd
    end
    else
    begin
      //sdd...
//      GiftCount := 0;
//      GiftAmount := 0;
      GiftCountNBS := 0;
      GiftAmountNBS := 0;
      //...sdd
    end;
    //sdd...
    Close;
    SQL.Clear;
//    SQL.Add('Select Count(*) as cnt2, sum(Amount) as amt2 from CCBatch where ');
    SQL.Add('Select Count(*) as cnt, sum(Amount) as amt from CCBatch where ');
    SQL.Add('HostID <> :pHostID and BatchID > :pMin and BatchID < :pMax and');
//    SQL.Add(' TransGroup = :pTransGroup and (NBSTranCode = :pAct2 or NBSTranCode = :pRec2)');
    SQL.Add(' TransGroup = :pTransGroup and (NBSTranCode = :pAct or NBSTranCode = :pRec)');
    parambyname('pHostID').AsInteger := CDTSRV_NBS;
    parambyname('pMin').AsString := inttostr(nStartBatch - 1);
    parambyname('pMax').AsString := inttostr(nEndBatch + 1);
    parambyname('pTransGroup').AsInteger := TG_ACTIVATION;
    parambyname('pAct').AsString := IntToStr(RT_ACTIVATE);
    parambyname('pRec').AsString := IntToStr(RT_GIFT_RELOAD);
    open;
    if fieldbyname('Cnt').asInteger > 0 then
    begin
      GiftCountOther := fieldbyname('Cnt').asInteger;
      GiftAmountOther := fieldbyname('amt').AsCurrency;
    end
    else
    begin
      GiftCountOther := 0;
      GiftAmountOther := 0;
    end;
    GiftCount  := GiftCountNBS  + GiftCountOther;
    GiftAmount := GiftAmountNBS + GiftAmountOther;
    //...sdd
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  LineOut('');
  LineOut('CARD TYPE SUMMARY:');
  LineOut('BATCHES ' + IntToStr(nStartBatch) + ' Thru ' + IntToStr(nEndBatch));

  CCRptByCardType(nStartBatch, nEndBatch, GiftAmount, GiftCount);

  //bp...
  //DSG
  if (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD]) then
  begin
    CCHostTotals(DayID);    // Host totals by card category
    CCLocalTotals(DayID);   // Local totals by card category
  end;
  // Host totals by card category
  //CCHostTotals(nDayID);
  // Local totals by card category
  //CCLocalTotals(nDayID);
  //...bp
  //DSG
  
  // Batch Summary
  CCBatchSummary();

  // Uncollected Summary By Batch
  if nCreditAuthType = CDTSRV_NBS then
    CCRptUncollected;

  CCRptUncollectedLocal;

  // Check for Auth 70's  --- ADS Only
  if nCreditAuthType = CDTSRV_ADS then
    CCTermSrvCheck;

  ReportFtr;
    
  AssignTransNo;
  rcptSale.nTransNo := curSale.nTransNo;
  nRcptShiftNo := nShiftNo;
  POSPrt.PrintSeq;
  LogRpt('Credit Totals Report');

  // Check for PDL Report  --- ADS Only
  if nCreditAuthType = CDTSRV_ADS then
    if nCreditBatchPDL = 1 then
      CreditSetup;

  if NOT (EODInProgress or EOSInProgress) then
    begin
      nCreditBatchID := 0;
      nCreditBatchPDL := 0;
    end;

  PRINTING_REPORT := False;
  if bClosePOSMsg then fmPOSMsg.Close;


End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CreditSetup
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.CreditSetup;
var
  bClosePOSMsg: Boolean;
Begin

  PRINTING_REPORT := True;

  bClosePOSMsg := Not(fmPOSMsg.Visible);
  fmPOSMsg.ShowMsg(' ', 'Printing Credit Setup...');
  CCSetupReport;
  if bClosePOSMsg then fmPOSMsg.Close;

  AssignTransNo;
  rcptSale.nTransNo := curSale.nTransNo;
  nRcptShiftNo := nShiftNo;
  POSPrt.PrintSeq;

  LogRpt('Credit Setup');
  PRINTING_REPORT := False;

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PLUReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Terminal, Shift : Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.PLUReport(DayId, Terminal, Shift : Integer);
Begin

  PRINTING_REPORT := True;
  PrintPLUReport(DayId, Terminal, Shift, ConsolidateShifts);
  AssignTransNo;
  rcptSale.nTransNo := curSale.nTransNo;
  nRcptShiftNo := nShiftNo;

  POSPrt.PrintSeq;
  LogRpt('PLU Sales Report');
  PRINTING_REPORT := False;

End;

procedure TfmPOS.PLUReportToDisk(DayId, Terminal, Shift : Integer);
Begin

  //PRINTING_REPORT := True;
  PrintPLUReportToDisk(DayId, Terminal, Shift, ConsolidateShifts);
  //AssignTransNo;
  rcptSale.nTransNo := curSale.nTransNo;
  nRcptShiftNo := nShiftNo;

  //POSPrt.PrintSeq;
  //LogRpt('PLU Sales Report');
  //PRINTING_REPORT := False;

End;


procedure TfmPOS.MOReport(ReportToDisk : boolean);
var
  tbool : boolean;
begin
  tbool := PRINTING_REPORT;
  PRINTING_REPORT := not ReportToDisk;
  PrintMOBatchReport();
  if PRINTING_REPORT then
    POSPrt.PrintSeq;
  PRINTING_REPORT := tbool;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CashDropReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Terminal, Shift : Integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.CashDropReport(DayId, Terminal, Shift : Integer);
Begin

  PRINTING_REPORT := True;
  PrintCashDropReport(DayId, Terminal, Shift, ConsolidateShifts);
  AssignTransNo;
  rcptSale.nTransNo := curSale.nTransNo;
  nRcptShiftNo := nShiftNo;

  POSPrt.PrintSeq;
  LogRpt('Cash Drop Report');
  PRINTING_REPORT := False;

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.HourlyReport
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Terminal, Shift : Integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.HourlyReport(DayId, Terminal, Shift : Integer);
begin

  PRINTING_REPORT := True;
  HourlySalesReport(DayId, Terminal, Shift, ConsolidateShifts);
  AssignTransNo;
  rcptSale.nTransNo := curSale.nTransNo;
  nRcptShiftNo := nShiftNo;
  POSPrt.PrintSeq;
  LogRpt('Hourly Sales Report');
  PRINTING_REPORT := False;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PLUList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.PLUList;
begin

  PRINTING_REPORT := True;
  PLUListingReport;
  AssignTransNo;
  rcptSale.nTransNo := curSale.nTransNo;
  nRcptShiftNo := nShiftNo;
  POSPrt.PrintSeq;
  LogRpt('PLU Listing Report');
  PRINTING_REPORT := False;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyEOD
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyEOD(const ResumeMode : TResumeKeyMode);
var
  DayId : Integer;
  DoBackup,Closeit, syncsave : boolean;
  pcount, PrtLoopCount : short;
  i, c : integer;
  TermNo, MaxTerm : short;
  ShiftCheckShift, ShiftCheckTerminal : integer;
  MsgStr : string;
  MadeFuelAdjust : boolean;
  CCMsg : string;
  CWMsg : string;
  FPCTimerStatus : boolean;
  AppPath, dirname, dirpath, zippath : string;
  StartTime : TDateTime;
begin
  if (ResumeMode = mResumeKeyInit) then
  begin
    if (not SalesComplete) then
      POSError('Finish All Sales Before Running End Of Day')
    else
      QueryLoggedOnInfo(LU_RET_EOD, 0);
      exit; 
  end
  else if (ResumeMode = mResumeKeyTerminalNotClosed) then
  begin
    POSError('Please Log-Off Other Terminals Before Running End Of Day');
    exit;
  end;

  // If no exit above, then this procedure was called after verfying that no other users logged in.

  if bEODPopUpMsg then
  begin
    for i:= 0 to PopUpMsgList.Count - 1 do
    begin
      PopUpMsg := PopUpMsgList.Items[i];
      if PopUpMsg^.MsgType = 1 then
      begin
        fmPopUpMsg.ShowModal;
        break;
      end;
    end;
  end;

  CloseIt := False;
  if fmPOSErrorMsg.YesNo('POS Confirm', 'End this Day') = mrOk then
  begin
    syncsave := SyncLogs;
    SyncLogs := True;
    PopUpMsgTimer.Enabled := False;
    fmPOS.Timer1.Enabled := False;  //20071018b
    CloseIt := True;
    fmPOSMsg.ShowMsg('Starting End of Day', '');
    MadeFuelAdjust := False;
    POSDataMod.IBRptTrans.StartTransaction;
    UpdateZLog('Opening IBRptTrans');
    with POSDataMod.IBRptSQL01Main do
    begin
      Assert(not Open, 'IBRptSQL01Main is open');
      DayId := POSDataMod.GetDayId(Transaction);
      SQL.Text := 'select * from fueltran where completed = 0';
      ExecQuery;
      while NOT EOF do
      begin
        MadeFuelAdjust := True;

        UpdateExceptLog('FuelAdjustMent ' + Trim(FieldByName('SaleType').AsString)
                                   + ' ID ' + IntToStr(FieldByName('SaleID').AsInteger)
                                   + ' Amount ' + CurrToStr(FieldByName('Amount').AsCurrency)
                                   + ' PPYAmount ' + CurrToStr(FieldByName('PrePayAmount').AsCurrency) );

        if  Trim(FieldByName('SaleType').AsString) = 'PPY' then
        begin
          if (FieldByName('PrePayAmount').AsCurrency > 0) and
                (FieldByName('Amount').AsCurrency = 0) then
          begin
            with POSDataMod.IBRptSQL01Sub1 do
            begin
              Assert(not Open, 'IBRptSQL01Sub1 is open');
              SQL.Clear;
              SQL.Add('UPDATE Totals SET ');
              SQL.Add('DlyPrePayCount = DlyPrePayCount - :pCount, ');
              SQL.Add('DlyPrePayRcvd = DlyPrePayRcvd - :pAmount, ');
              SQL.Add('FuelCount = FuelCount - :pCount, ');
              SQL.Add('FuelAmount = FuelAmount - :pAmount, ');
              SQL.Add('CurGT = CurGT - :pAmount, ');
              SQL.Add('DlyDS = DlyDS - :pAmount, ');
              SQL.Add('DlyND = DlyND - :pAmount, ');
              SQL.Add('DlyNoTax = DlyNoTax - :pAmount ');
              SQL.Add('WHERE ((TotalNo = 0) Or ((ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo)))');
              ParamByName('pCount').AsCurrency := 1;
              ParamByName('pAmount').AsCurrency := (POSDataMod.IBEODQuery.FieldByName('PrePayAmount').AsCurrency );
              ParamByName('pShiftNo').AsInteger := nShiftNo;
              ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
              ExecQuery;
              Close;
            end;
            with POSDataMod.IBRptSQL01Sub1 do
            begin
              Assert(not Open, 'IBRptSQL01Sub1 is open');
              SQL.Clear;
              SQL.Add('UPDATE MedShift SET ');
              SQL.Add('DlyCount = DlyCount - 1, ');
              SQL.Add('DlySales = DlySales - :pAmount ');
              SQL.Add('WHERE (DayId = :pDayId) and (MediaNo = 1) and (ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo)');
              ParamByName('pDayId').AsInteger := DayId;
              ParamByName('pAmount').AsCurrency := (POSDataMod.IBEODQuery.FieldByName('PrePayAmount').AsCurrency);
              ParamByName('pShiftNo').AsInteger := nShiftNo;
              ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
              ExecQuery;
              Close;
            end;
          end;
        end;
        POSDataMod.IBRptSQL01Main.Next;
      end;
      POSDataMod.IBRptSQL01Main.Close;
    end;
    if MadeFuelAdjust then
    with POSDataMod.IBRptSQL01Main do
    begin
      Assert(not Open, 'IBRptSQL01Main is open');
      SQL.Text := 'Update fueltran set completed = 1, PaySource = ''EOD'' where completed = 0';
      ExecQuery;
      Close;
    end;
    if Setup.MeterReport = 1 then
    begin
      fmPOS.SendFuelMessage( 0, PMP_ALLSTOP, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP)
    end
    else
    begin
      fmPOS.SendFuelMessage( 0, PMP_PAUSEALL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP )
    end;
    for c := 1 to 1000 do
      Application.ProcessMessages;

    for c := 1 to 200 do
    begin
      Application.ProcessMessages;
      sleep(1);
    end;

    for c := 1 to 1000 do
      Application.ProcessMessages;

    fmPOS.Refresh;

    OpenDrawer;
    PausePrint;

    DAYCLOSEInProgress := True;
    EOSInProgress := True;
    fCreditTotals   := True;
    nCreditBatchID  := 0;
    nCreditBatchPDL := 0;
    if Setup.CreditAuthType > 1 then
    begin
      //Build 16
      //CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_CLOSEBATCH));
      CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_CLOSEBATCH)) +
                  BuildTag(TAG_EOD_IN_PROGRESS, IntToStr(Integer(DAYCLOSEInProgress)));
      //Build 16
      SendCreditMessage(CCMsg);
    end;
    //cwj...
    if Setup.CarwashInterfaceType <> CWSRV_NONE then
    begin
      fCarwashTotals := True;
      CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_EOD_AUDIT_REQUEST)) +
                  BuildTag(CWTAG_EOD_IN_PROGRESS, IntToStr(Integer(DAYCLOSEInProgress)));
      SendCarwashMessage(CWMsg);
    end
    else
    begin
      fCarwashTotals := False;
    end;
    //...cwj
    // Look For any Unclosed Shifts with sales
    Assert(not POSDataMod.IBRptSQL01Main.Open, 'IBRptSQL01Main is open');
    POSDataMod.IBRptSQL01Main.SQL.Text := 'select TerminalNo, ShiftNo from totals where closedate is null and totalno > 0 and DLYDS <> 0';
    POSDataMod.IBRptSQL01Main.ExecQuery;
    while NOT POSDataMod.IBRptSQL01Main.Eof do
    begin
      ShiftCheckTerminal := POSDataMod.IBRptSQL01Main.FieldByName('TerminalNo').AsInteger;
      ShiftCheckShift    := POSDataMod.IBRptSQL01Main.FieldByName('ShiftNo').AsInteger;

      MsgStr := 'End of Shift# ' + IntToStr(ShiftCheckShift) + ' Terminal# ' + IntToStr(ShiftCheckTerminal);
      fmPOSMsg.ShowMsg(MsgStr, '');

      //cwe         PrtLoopCount := 1;
      PrtLoopCount := Setup.EOSReportCount;
      if (PrtLoopCount < 1) or (PrtLoopCount > 5) then PrtLoopCount := 1;
      for PCount := 1 to PrtLoopCount do
      begin
        ReportToDisk :=  (PCount = 1);
        if ReportToDisk then
            LogReportMarker('^^^EOS ' + Format('%2.2d %1.1d', [ShiftCheckTerminal, ShiftCheckShift]));

        LAST_REPORT := False;
        if bEOSRptDaily then
        begin
          fmPOSMsg.ShowMsg('', 'Preparing Shift Daily Sales');
          PrintDailyReport(DayId, ShiftCheckTerminal, ShiftCheckShift);
        end;
        if bEOSRptHourly then
        begin
          fmPOSMsg.ShowMsg('', 'Preparing Shift Hourly Sales');
          HourlyReport(DayId, ShiftCheckTerminal, ShiftCheckShift);
        end;

        if bEOSRptFuelTls then
        begin
          fmPOSMsg.ShowMsg('', 'Preparing Fuel Totals');
          if PCount = 1 then
            FuelTotalsReport(False)
          else
            FuelTotalsReport(True);
        end;


        if bEOSRptCashDrop then
        begin
          fmPOSMsg.ShowMsg('', 'Preparing Cash Drop Report');
          CashDropReport(DayId, ShiftCheckTerminal, ShiftCheckShift);
        end;


        if bEOSRptPLU then
        begin
          fmPOSMsg.ShowMsg('', 'Preparing PLU Sales Report');
          if ReportToDisk then
            PLUReportToDisk(DayId, ShiftCheckTerminal, ShiftCheckShift);
          PLUReport(DayId, ShiftCheckTerminal, ShiftCheckShift);
        end;

        if bEOSRptCredit then
        begin
          fmPOSMsg.ShowMsg('', 'Preparing Credit Sales Report');
          CreditReport(DayId, ShiftCheckShift);
        end;

        if ReportToDisk then
          LogReportMarker('^^^END');
      end;

      fmPOSMsg.ShowMsg('', 'Preparing to reset day');

      ReportToDisk := False;
      {... and we log the action : }
      LogRpt('End of Shift# ' + IntToStr(ShiftCheckShift)  + ' Reports');


      If EOSExports Then
      begin
        fmPOSMsg.ShowMsg('', 'Creating Shift Export File...');
        CreateExportFile (ShiftCheckTerminal, ShiftCheckShift, CurrentUser);
      end;

      LAST_REPORT := True;
      PrintResetChit( 'Shift# ' + IntToStr(ShiftCheckShift));

      //Build 34
      // Mark the shift as closed
      with POSDataMod.IBRptSQL01Sub1 do
      begin
        Assert(not open, 'IBRptSQL01Sub1 is open');
        SQL.Text := 'UPDATE Totals SET CloseDate = :pDate WHERE (ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo)';
        ParamByName('pShiftNo').AsInteger := ShiftCheckShift;
        ParamByName('pTerminalNo').AsInteger := ShiftCheckTerminal;
        ParamByName('pDate').AsDateTime := Now();
        ExecQuery;
        Close;
      end;

      with POSDataMod.IBRptSQL01Sub1 do
      begin
        Assert(not open, 'IBRptSQL01Sub1 is open');
        SQL.Text := 'Update Terminal Set ResetCount = ResetCount + 1 Where TerminalNo = :pShiftCheckTerminal ';
        parambyname('pShiftCheckTerminal').AsString := IntToStr(ShiftCheckTerminal);
        ExecQuery;
        Close;
      end;
      try
        POSDataMod.IBRptSQL01Main.Next;
      except
        fmPOSMsg.ShowMsg('', 'Error on Next...');
        sleep(10000);
      end;
    end;

    POSDataMod.IBRptSQL01Main.Close;

    with POSDataMod.IBRptSQL01Sub1 do
    begin
      Assert(not open, 'IBRptSQL01Sub1 is open');
      SQL.Text := 'UPDATE Totals SET CloseDate = :pDate WHERE TOTALNO=0';
      ParamByName('pDate').AsDateTime := Now();
      ExecQuery;
      Close;
    end;
    POSDataMod.IBRptTrans.Commit;
    POSDataMod.IBRptTrans.StartTransaction;

    EOSInProgress := False;
    EODInProgress := True;
    { We end the day...}

    { send command to MCP to move data here }
    fPushedEOD := True;
    StartTime := Now();
    sendMCPMessage(BuildTag(TAG_MSGTYPE, IntToStr(MCP_PUSH_EOD_DATA))
                   + BuildTag(IntToStr(MCP_DAYID), IntToStr(DayId)));

    fmPOSMsg.ShowMsg('End of Day In Progress...', '');

    //cwe     PrtLoopCount := 1;
    PrtLoopCount := Setup.EODReportCount;
    if (PrtLoopCount < 1) or (PrtLoopCount > 5) then
      PrtLoopCount := 1;

    for c := 1 to 100 do
      Application.ProcessMessages;

    for PCount := 1 to PrtLoopCount do
    begin
      ReportToDisk :=  (PCount = 1);
      if ReportToDisk then
        LogReportMarker('^^^EOD');

      LAST_REPORT := False;

      if bEODRptDaily then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Daily Sales');
        PrintDailyReport(DayId, 0, 0);
      end;

      if bEODRptHourly then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Hourly Sales');
        HourlyReport(DayId, 0, 0);
      end;

      if bEODRptFuelTls then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Fuel Totals');
        if PCount = 1 then
          FuelTotalsReport(False)
        else
          FuelTotalsReport(True);
      end;

      if bEODRptCashDrop then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Cash Drop Report');
        CashDropReport(DayId, 0, 0);
      end;

      if bEODRptPLU then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing PLU Sales Report');
        if ReportToDisk then
          PLUReportToDisk(DayId, 0, 0);
        PLUReport(DayId, 0, 0);
      end;

      fmPosMsg.ShowMsg('', 'Preparing Hourly Activity Report');
      HourlySnoopReport(DayId, 0, 0, ConsolidateShifts);

      if Setup.MOSystem then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing MO Reports');
        MOReport(ReportToDisk);
      end;
      
      LAST_REPORT := True;

      fmPOSMsg.ShowMsg('', 'Preparing Credit Sales Report');
      CreditReport(DayId, 0);

      fmPOSMsg.ShowMsg('', 'Preparing Activate Void Report');
      PrintFailedToActivateReport(DayId, 0, 0);

      if ReportToDisk then
        LogReportMarker('^^^END');
    end;
    {... and we log the action : }
    LogRpt('End of Day Reports');
    ReportToDisk :=  False;

    nCreditBatchID := 0;
    nCreditBatchPDL := 0;

    If EODExports Then
    begin
      fmPOSMsg.ShowMsg('', 'Creating EOD Export File...');
      CreateExportFile (0, 0, CurrentUser);
    end;
    if Setup.MOSystem then
    begin
      c := 1;
      while c < 5 do
      try
        MO.SendMsg(BuildTag(TAG_MOCMD, IntToStr(CMD_MOPRODUCESETTLEMENT)) +
                   BuildTag(TAG_MOFILENAME, ExtractFileDir(Application.ExeName) + '\' + RightStr( '00' + Trim(Setup.NUMBER), 3 ) + '_' + FormatDateTime('YYYYMMDDHHMM', Now()) + '.cec'));
        break;
      except
        on E: Exception do
        begin
          UpdateExceptLog('Cannot send ProduceSettlement command to MO Server %s: %s', [e.classname, e.message]);
          inc(c);
        end;
      end;
      if c = 5 then
        POSError('Could not create MO Settlement! Call support');
    end;

    AppPath := ExtractFileDir(Application.ExeName) + PathDelim;
    dirpath := GetExportPath(apppath);
    ExportDayAgnostic(dirpath);

    while fPushedEOD = True do
    begin
      Application.ProcessMessages;
      sleep(200);
      if TimerExpired(StartTime, 45) then
      begin
        fPushedEOD := False;
        UpdateExceptLog('Warning - EOD Data move timer expired instead of being notified by MCP');
      end
      else
        fmPOSMsg.ShowMsg('', 'Waiting for EOD data move - ' + IntToStr(45 - SecondsBetween(Now(),StartTime)));
    end;

    { Now we reset all the Tables : }
    fmPOSMsg.ShowMsg('', 'Resetting Daily Totals...');
    ResetDay;

    //****************** MDS somewhere after this is where EOD is as Dave calls it PUCKING

    POSDataMod.IBRptTrans.Commit;
    UpdateZLog('Day Reset, committed transaction');

    PrintResetChit('Day');
    AssignTransNo;
    rcptSale.nTransNo := curSale.nTransNo;
    nRcptShiftNo := nShiftNo;
    POSPrt.PrintSeq;
    LogRpt('End Of Day Reset Complete');

    SyncLogs := SyncSave;

    if Not SoftwareUpdatePending then
      ReleasePumps();

    fmPOSMsg.ShowMsg('', 'Exporting Totals to Text Files...');
    POSDataMod.IBRptTrans.StartTransaction;
    ZipTotals(DayId, apppath, dirpath);
    POSDataMod.IBRptTrans.Commit;

    fmPOSMsg.ShowMsg('', 'Cleaning Up History...');

    CleanUpDir ('\\' + fmPOS.MasterTerminalUNCName + '\' + fmPOS.MasterTerminalAppDrive + '\Latitude\History', '*.zip', nDaysHistory);
    CleanUpDir ('\\' + fmPOS.MasterTerminalUNCName + '\' + fmPOS.MasterTerminalAppDrive + '\Latitude\History', '*.', nDaysHistory);
    CleanUpDir ('\\' + fmPOS.BackUpTerminalUNCName + '\' + fmPOS.BackUpTerminalAppDrive + '\Latitude\History', '*.zip', nDaysHistory);
    {$IFDEF DAX_SUPPORT}  //20071128d...  (logic had been in ZipTotals())
    CleanUpDir ('\\' + fmPOS.MasterTerminalUNCName + '\' + fmPOS.MasterTerminalAppDrive + '\Latitude\History', 'POS_' + RightStr('000' + Setup.Number,3) + '_*.txt', nDaysHistory);
    {$ENDIF}              //...20071128d

    fmPOSMsg.ShowMsg('', 'Cleaning Up DB Backups...');

    CleanUpDir ('\\' + fmPOS.MasterTerminalUNCName + '\' + fmPOS.MasterTerminalAppDrive + '\Latitude\BackUp', '*.*', nDaysBackUp);
    CleanUpDir ('\\' + fmPOS.BackUpTerminalUNCName + '\' + fmPOS.BackUpTerminalAppDrive + '\Latitude\BackUp', '*.*', nDaysBackUp);


    if (Now() - Setup.LastBackUp) > Setup.BackUpInterval then
    begin
      case dayofweek(now) of
         1 :  DoBackup := (Setup.BackUpAllowedSun = 1);
         2 :  DoBackup := (Setup.BackUpAllowedMon = 1);
         3 :  DoBackup := (Setup.BackUpAllowedTue = 1);
         4 :  DoBackup := (Setup.BackUpAllowedWed = 1);
         5 :  DoBackup := (Setup.BackUpAllowedThr = 1);
         6 :  DoBackup := (Setup.BackUpAllowedFri = 1);
         7 :  DoBackup := (Setup.BackUpAllowedSat = 1);
         else
           DoBackup := False;
      end;
      if DoBackup then
      begin
        {$IFDEF ESF_NET}//20070515a
        if not EODInProgress then
        {$ENDIF}
        begin
        CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_PAUSECREDIT));
        SendCreditMessage(CCMsg);
        end;
        
        FPCTimerStatus := FPCPostTimer.Enabled;
        FPCPostTimer.Enabled := False;

        //cwa...
        //Build 25
        CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_PAUSE_SERVER));
        SendCarWashMessage(CWMsg);
        (*if Setup.CarWashInterfaceType <> 1 then
        begin
          CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_PAUSE_SERVER));
          SendCarWashMessage(CWMsg);
        end;
        //Build 25
        //...cwa*)

        BackupAndRestore;

        {$IFDEF ESF_NET}//20070515a
        if not EODInProgress then
        {$ENDIF}
        begin
          CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_RESUMECREDIT));
          SendCreditMessage(CCMsg);
        end;

        FPCPostTimer.Enabled := FPCTimerStatus;

        //cwa...
        //Build 25
        CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_RESUME_SERVER));
        SendCarWashMessage(CWMsg);
        (*if Setup.CarWashInterfaceType <> 1 then
        begin
          CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_RESUME_SERVER));
          SendCarWashMessage(CWMsg);
        end;*)
        //Build 25
        //...cwa
      end;
    end;
    ResumePrint;

    if SoftwareUpdatePending then
      ApplySoftwareUpdate;

    fmPOSMsg.Close;
    if SoftwareUpdatePending then
      ReleasePumps();

    {$IFDEF ESF_NET}//20070515a
    // Restart ESF Buypass credit server (was shutdown at start of EOD).
    fmPOS.ConnectCreditServer();
    {$ENDIF}
  end;

  //20061207a...
  if (Setup.EODExport = 3) or (Setup.EOSExport = 3) then
    ImportPDIPLU;
  //...20061207a

  //20071018b...Update Kiosk prices if Kiosk is active
  if bKioskActive then
    UpdateKioskPrices();  //20071107f
  //...20071018b

  fmPOSErrorMsg.ModalResult := mrOK;
  fmPOSErrorMsg.Visible := False;
  fmPOSErrorMsg.ShowYesNo := False;

  StatusBar1.Panels.Items[0].Text := 'Terminal# ' + IntToStr(ThisTerminalNo) + ' Shift# ' + InttoStr (nShiftNo);

  fmPOS.Timer1.Enabled := True;  //20071018b
  fmPOS.PopUpMsgTimer.Enabled := True;  //20071018b

  { The User has to sign on again }
  if CloseIt then
  begin
    ProcesskeyUSO;
    PopUpMsgTimer.Enabled := True;
  end;
  try
    ShellExecute(Handle,'open','DBUpdateSQL.exe', '',  PChar(ExtractFileDir(Application.ExeName)) ,SW_HIDE);
  except
  end;

End;

procedure TfmPOS.ReleasePumps();
var
  c : integer;
begin
  if NOT bPOSForceClose then
  begin
    EODInProgress := False;
    DAYCLOSEInProgress := False;
    if Setup.MeterReport = 1 then
    begin
      fmPOS.SendFuelMessage( 0, PMP_ALLRESUME, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP )
    end
    else
    begin
      fmPOS.SendFuelMessage( 0, PMP_RESUMEALL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP )
    end;
    for c := 1 to 10000 do
      Application.ProcessMessages;
    fmPOS.Refresh;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyEOS
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyEOS(const ResumeMode : TResumeKeyMode);
var
CloseIt : boolean;
pcount, PrtLoopCount : short;
i : short;
TermNo : short;
RptTerminalNo, RptSHiftNo : short;
ShiftMsgStr : string;
CCMsg : string;
  DayId : integer;
begin
  if ((ResumeMode = mResumeKeyInit) and bSyncShiftChange) then
  begin
    QueryLoggedOnInfo(LU_RET_EOS, 0);
    exit;
  end
  else if (ResumeMode = mResumeKeyTerminalNotClosed) then
  begin
    POSError('Please Log-Off Other Terminals Before Running End Of Shift');
    exit;
  end;

  // If no exit above when bSyncShiftChange is true, then this procedure was called after verfying that no other users logged in.
  // (If bSyncShiftChange is false, then logged on information request is never queued, so processing will continue here after
  // ProcessKeyEOS is first called.)

  if (bSyncShiftChange) then
    RptTerminalNo := 0
  else
    RptTerminalNo := ThisTerminalNo;

  RptShiftNo := nShiftNo;
  DayId := 0;  // reports default to running for today if dayid == 0;

  if bEOSPopUpMsg then
  begin
    for i:= 0 to PopUpMsgList.Count - 1 do
    begin
      PopUpMsg := PopUpMsgList.Items[i];
      if PopUpMsg^.MsgType = 2 then
      begin
        fmPopUpMsg.ShowModal;
        break;
      end;
    end;
  end;

  CloseIt := False;
  If fmPOSErrorMsg.YesNo('POS Confirm', 'End the Shift # '+ InttoStr(nShiftNo)) = mrOk Then
  Begin
    PopUpMsgTimer.Enabled := False;
    Timer1.Enabled := false;    //20071113d
    CloseIt := True;
    EOSInProgress := True;
    OpenDrawer;
    PausePrint;
    POSDataMod.IBRptTrans.StartTransaction;
    if bEOSBatchBalance then
    begin
      if Setup.CreditAuthType > 1 then
      begin
        fCreditTotals := True;
        nCreditBatchID := 0;
        nCreditBatchPDL := 0;
        //Build 16
        //CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_CLOSEBATCH));
        CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_CLOSEBATCH)) +
          BuildTag(TAG_EOD_IN_PROGRESS, IntToStr(Integer(DAYCLOSEInProgress)));
        //Build 16
        SendCreditMessage(CCMsg);
      end;
    end
    else
    begin
      with POSDataMod.IBRptSQL01Main do
      begin
        Assert(not open, 'IBRptSQL01Main is open');
        fCreditTotals := False;
        nCreditBatchID := 0;
        nCreditBatchPDL := 0;
        SQL.Text := 'SELECT Max(BatchID) BatchID FROM CCRTB';
        ExecQuery;
        if Not EOF then
          nCreditBatchID := FieldByName('BatchID').AsInteger;
        Close;
      end;
    end;
    with POSDataMod.IBRptSQL01Main do
    begin
      Assert(not open, 'IBRptSQL01Main is open');
      SQL.Text := 'UPDATE Totals SET CloseDate = :pDate WHERE ShiftNo = :pShiftNo';
      if RptTerminalNo > 0 then
      begin
        SQL.Add('and TerminalNo = :pTerminalNo');
        parambyname('pTerminalNo').AsInteger := RptTerminalNo;
      end;
      parambyname('pShiftNo').AsInteger := RptShiftNo;
      ParamByName('pDate').AsDateTime := Now();
      ExecQuery;
      Close;
      SQL.Text := 'Update Terminal Set CurShift = CurShift + 1, ResetCount = ResetCount + 1';
      if NOT bSyncShiftChange then
      begin
        SQL.Add('Where TerminalNo = :pTerminalNo');
        parambyname('pTerminalNo').AsInteger := RptTerminalNo;
      end;
      ExecQuery;
      Close;
      SQL.Text := 'Select CurShift From Terminal Where TerminalNo = :pTerminalNo';
      parambyname('pTerminalNo').AsInteger := ThisTerminalNo;
      ExecQuery;
      nShiftNo := FieldByName('CurShift').AsInteger;
      Close;

      fmPOSMsg.ShowMsg('', 'Initializing Totals For Shift# ' + IntToStr(nShiftNo));

      if bSyncShiftChange then
      begin
        SQL.Text := 'Select TerminalNo from Terminal order by TerminalNo';
        ExecQuery;
        while not EOF do
        begin
          TermNo := Fields[0].AsInteger;
          InitShiftTotals(TermNo, nShiftNo);
          next;
        end;
        Close;
        InitShiftTotals(99, nShiftNo);
      end
      else
      begin
        InitShiftTotals(ThisTerminalNo, nShiftNo);
        if ThisTerminalNo = MasterTerminalNo then
          InitShiftTotals(99, nShiftNo);
      end;
    end;  { with POSDataMod.IBRptSQL01Main }
    ShiftMsgStr := 'End of Shift# ' + IntToStr(RptShiftNo);
    if RptTerminalNo > 0 then
      ShiftMsgStr := ShiftMsgStr + ' Terminal# ' + IntToStr(RptTerminalNo);
    fmPOSMsg.ShowMsg(ShiftMsgStr, '');

    //cwe     PrtLoopCount := 1;
    PrtLoopCount := Setup.EOSReportCount;
    if (PrtLoopCount < 1) or (PrtLoopCount > 5) then
      PrtLoopCount := 1;

    for PCount := 1 to PrtLoopCount do
    begin
      ReportToDisk :=  (PCount = 1);
      if ReportToDisk then
        LogReportMarker('^^^EOS ' + Format('%2.2d %1.1d', [RptTerminalNo, RptShiftNo]));

      LAST_REPORT := False;
      if bEOSRptDaily then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Shift Daily Sales');
        try
          PrintDailyReport(DayId, RptTerminalNo, RptShiftNo);
        except
          UpdateExceptLog('Unable to Complete Shift Daily Sales Report');
        end;
      end;

      if bEOSRptHourly then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Shift Hourly Sales');
        try
          HourlyReport(DayId, RptTerminalNo, RptShiftNo);
        except
          UpdateExceptLog('Unable to Complete Shift Hourly Sales Report');
        end;
      end;

      if bEOSRptFuelTls then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Fuel Totals');
        if PCount = 1 then
          FuelTotalsReport(False)
        else
          FuelTotalsReport(True);
      end;

      if bEOSRptCashDrop then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Cash Drop Report');
        try
          CashDropReport(DayId, RptTerminalNo, RptShiftNo);
        except
          UpdateExceptLog('Unable to Complete Shift Cash Drop Report');
        end;
      end;

      if bEOSRptPLU then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing PLU Sales Report');
        try
          if ReportToDisk then
            PLUReportToDisk(DayId, RptTerminalNo, RptShiftNo);
          PLUReport(DayId, RptTerminalNo, RptShiftNo);
        except
          UpdateExceptLog('Unable to Complete Shift PLU Sales Report');
        end;
      end;

      if bEOSRptCredit then
      begin
        fmPOSMsg.ShowMsg('', 'Preparing Credit Sales Report');
        try
          CreditReport(DayId, RptShiftNo);
        except
          UpdateExceptLog('Unable to Complete Credit Sales Report');
        end;
      end;

      if ReportToDisk then
        LogReportMarker('^^^END');

    end;

    ReportToDisk := False;
    {... and we log the action : }

    nCreditBatchID := 0;
    nCreditBatchPDL := 0;

    If EOSExports Then
    begin
      fmPOSMsg.ShowMsg('', 'Creating Shift Export File...');
      try
        CreateExportFile (RptTerminalNo, RptShiftNo, CurrentUser);
      except
        UpdateExceptLog('Unable to Create Shift Files Terminal: '+
          inttostr(RptTerminalNo)+' Shift: '+inttostr(RptShiftNo));
      end;
    end;
    POSDataMod.IBRptTrans.Commit;

    LAST_REPORT := True;
    PrintResetChit( 'Shift# ' + IntToStr(RptShiftNo));
    AssignTransNo;
    rcptSale.nTransNo := curSale.nTransNo;
    nRcptShiftNo := nShiftNo;

    POSPrt.PrintSeq;

    LogRpt('End of Shift Reports');

    ResumePrint;

    curSale.nTransNo := 0;

    EOSInProgress := False;

  End;

  StatusBar1.Panels.Items[0].Text := 'Terminal# ' + IntToStr(ThisTerminalNo) + ' Shift# ' + InttoStr (nShiftNo);

  fmPOSErrorMsg.Visible := False;
  fmPOSErrorMsg.ModalResult := mrOK;
  fmPOSErrorMsg.ShowYesNo := False;

  fmPOSMsg.Close;

  { The User has to sign on again }
  if CloseIt then
  begin
    ProcesskeyUSO;
    PopUpMsgTimer.Enabled := True;
  end;
End;


{-----------------------------------------------------------------------------
  Name:      tfmPOS.ProcessKeyPLR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure tfmPOS.ProcessKeyPLR;
Begin
  { We have to print the last receipt }
  { Only one print is allowed, afterwards the normal PrintReceipt has to be used }

  If PRINT_ON_REQUEST = True Then
    Begin
      if ReceiptList.Count = 0 Then
        begin
          POSError ('No Receipt data found');
          Exit;
        End;
      PrintReceiptFromReceiptList(ReceiptList);
      EmptyReceiptList;
    End; {if PRINT_ON_REQUEST}

End;


{-----------------------------------------------------------------------------
  Name:      tfmPOS.ProcessKeyPFL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure tfmPOS.ProcessKeyPFL;
Begin
  { We have to print the last receipt --- FUEL ONLY }
  { Only one print is allowed, afterwards the normal PrintReceipt has to be used }

  If PRINT_ON_REQUEST = True Then
    Begin
      if ReceiptList.Count = 0 Then
        begin
          POSError ('No Receipt data found');
          Exit;
        End;
      PrintFuelOnlyReceiptFromReceiptList(ReceiptList);
      EmptyReceiptList;
    End; {if PRINT_ON_REQUEST}

End;


procedure TfmPOS.ProcessKeyREC;
var
//20070525b  bFound : boolean;
  LastTransNo : Integer;
begin
  try
    fmOldReceipt.Visible := False;
    If Not(fmOldReceipt.Visible) Then
      begin
        if fmOldReceipt.ShowModal = mrOk then
          PRINT_OLD_RECEIPT := True
        else
          begin
            PRINT_OLD_RECEIPT := False;
            exit;
          end;
      end;
    fmOldReceipt.ModalResult := mrOK;
    fmOldReceipt.Visible := False;
  except
    fmOldReceipt.ModalResult := mrOK;
    sleep(100);
    exit;
  end;

  nCurMenu := Setup.ReprintMenu;
  DisplayMenu(nCurMenu);

  { We load the last Receipt }
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTotalsQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('select max(TransactionNo) as TransactionNo from Receipt');
    Open;
    LastTransNo := FieldByName('TransactionNo').AsInteger;
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  POSListBox.Clear;

//20070525b  bFound := False;
  nOldTransNo := LastTransNo;
  //20070525b...
//  for LastTransNo := LastTransNo downto (LastTransNo - 5)  do
//  begin
//    if LoadReceipt(LastTransNo) then
//    begin
//      bFound := True;
//      break;
//    end;
//  end;
//
//  if not bFound then
  if (not LoadReceipt(LastTransNo, mReceiptDirectionBack)) then
  //...20070525b
  begin
    POSError('No Receipt Data Found');
    exit;
  end;

  DisplayReceiptlines;
  lSuspend.Caption  := 'Print Receipt';

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisplayReceiptlines
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
Procedure TfmPOS.DisplayReceiptlines;
Var
  i   : Integer;
  sDisplay : string;
  SD : pSalesData;
Begin

  StatusBar1.Panels.Items[1].Text := 'Trans# ' + InttoStr(nOldTransNo);

  lTotal.Visible := False;
  eTotal.Text := '';
  eTotal.Visible := False;

  curSale.nFuelSubtotal := 0;
  curSale.nFSSubtotal := 0;
  curSale.nSubtotal := 0;
  curSale.nTlTax := 0;
  curSale.bSalesTaxXcpt := False;
  curSale.nTotal := 0;
  curSale.nAmountDue := 0;
  curSale.nChangeDue := 0;

  POSListBox.Clear;

  if CurSaleList.Count > 0 then
  begin
    For i:= 0 to CurSalelist.Count-1 do
    Begin
      If i = 0 Then
      Begin
       { We set the totals... }
        curSale.nFSSubtotal := nRecFSSubtotal;
        curSale.nSubtotal   := nRecSubtotal;
        curSale.nTlTax      := nRecTlTax;
        curSale.nTotal      := nRecTotal;
        curSale.nChangeDue  := nRecChangeDue;
        curSale.bSalesTaxXcpt  := bRecTaxXcpt;
      End;

      SD := CurSaleList.Items[i];

      If (SD^.LineType <> 'MED') and
         {$IFDEF MULTI_TAX}
         (SD^.LineType <> 'TAX') and
         {$ENDIF}
         (SD^.LineType <> 'XMD')         or
            ((SD^.Name = 'Fuel Discount') and (SD^.LineType = 'XMD')) then
      Begin
        {$IFDEF FUEL_PRICE_ROLLBACK}
        DisplaySaleList(SD,False);
        {$ELSE}
        DisplaySaleList(SD);
        {$ENDIF}
        DisplaySaleTotal;

      End;
    End;
    UpdateZLog('Calling BeginToFinalize : local');
    BeginToFinalize;
    UpdateZLog('Returned from BeginToFinalize : local');
    For i:= 0 to CurSalelist.Count-1 do
    Begin
      SD := CurSaleList.Items[i];
      If SD^.LineType = 'MED' Then
      begin
        sDisplay := Format('%23s',[SD^.Name]) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',SD^.ExtPrice))]);
        POSListBox.AddLast(sDisplay);
      end;
    End;

    sDisplay := Format('%23s',['Your Change']) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nChangeDue))]);
    POSListBox.AddLast(sDisplay);

     eTotal.Visible := False;
  end;
  POSListBox.Refresh;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisplayReceipts
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.DisplayReceipts(const sKeyType : string);
Var
//20070525b  bFound      : boolean;
  nSavTransNo : integer;
//20070525b  OldTransNo  : Integer;
  ndx         : Integer;
//bp...
  bCreditVoided : boolean;
  {$IFDEF TEST_VOID_AUTH}
  VoidCardNo : string;
//...bp
//bpd...
  bWasDebit : boolean;
//...bpd
//bph...
  RepeatCount : integer;
//...bph
  {$ENDIF}
  {$IFDEF FF_PROMO}
  FFCouponCount : integer;
  FuelFirstCouponAuthID : integer;
  {$ENDIF}
  SD : pSalesData;
Begin
  if sKeyType = 'UP ' then           { Up Arrow }
    Begin
      nSavTransNo := nOldTransNo;
      nOldTransNo := nOldTransNo - 1;
      DisposeSalesListItems(CurSaleList);
     //20070525b...
//      bFound := False;
//      OldTransNo := nOldTransNo;
//      for OldTransNo := OldTransNo downto (OldTransNo - 5)  do
//        begin
//          if LoadReceipt(OldTransNo) then
//            begin
//              bFound := True;
//              //53o...
//              nOldTransNo := OldTransNo;
//              //...53o
//              break;
//            end;
//        end;
//      if not bFound then
      if (not LoadReceipt(nOldTransNo, mReceiptDirectionBack)) then
      //...20070525b
        begin
          POSError('No Receipt Data Found');
          nOldTransNo := nSavTransNo;
          //53o...
          //20070525b...
//          LoadReceipt(nOldTransNo);
          LoadReceipt(nOldTransNo, mReceiptDirectionNone);
          //...20070525b
          //...53o
        end;
      //53o...
//      LoadReceipt(nOldTransNo);
      //...53o
      DisplayReceiptlines;

    End
  else if sKeyType = 'DN ' then      { Down Arrow }
    Begin

      nSavTransNo := nOldTransNo;
      nOldTransNo := nOldTransNo + 1;
      DisposeSalesListItems(CurSaleList);
      //20070525b...
//      bFound := False;
//      OldTransNo := nOldTransNo;
//      for OldTransNo := OldTransNo to OldTransNo + 5  do
//        begin
//          if LoadReceipt(OldTransNo) then
//            begin
//              bFound := True;
//              //53o...
//              nOldTransNo := OldTransNo;
//              //...53o
//              break;
//            end;
//        end;
//      if not bFound then
      if (not LoadReceipt(nOldTransNo, mReceiptDirectionForward)) then
      //...20070525b
        begin
          POSError('No Receipt Data Found');
          nOldTransNo := nSavTransNo;
          //53o...
          //20070525b...
//          LoadReceipt(nOldTransNo);
          LoadReceipt(nOldTransNo, mReceiptDirectionNone);
          //...20070525b
          //...53o
        end;

      //53o...
//      LoadReceipt(nOldTransNo);
      //...53o
      DisplayReceiptlines;
    End
//bp...
//  else if ((sKeyType = 'CLR') or (sKeyType = 'ENT') or (sKeyType = 'PFL')) then      { CLEAR }
//    Begin
//     { All that is left is to print the receipt }
//
//      If (sKeyType = 'ENT') or (sKeyType = 'PFL') Then
//        Begin
//          Begin
//
//            PrintReprint;
  else if ((sKeyType = 'CLR') or (sKeyType = 'ENT') or (sKeyType = 'PFL') or (sKeyType = 'VCA')) then
    Begin
      bCreditVoided := False;  // Initial assumption.
      {$IFDEF TEST_VOID_AUTH}
      if (sKeyType = 'ENT') then  // (todo) - Use 'VCA' button once button defined in DB.
        begin
          for ndx := 0 to (CurSaleList.Count - 1) do
            begin
              CurSaleData := CurSaleList.Items[ndx];
              //bpk...
              if (CurSaleData^.CCRequestType = RT_PURCHASE_REVERSE) then
                  break;                                         // can't reverse a reversal
              //...bpk
              VoidCardNo := Trim(CurSaleData^.CCCardNo);
              if ((CurSaleData^.LineType = 'MED') and
                  (CurSaleData^.ExtPrice > 0.0  ) and (VoidCardNo <> '')) then
                begin
                  //53o...
//                  bWasDebit := (CurSaleData^.Number = StrToInt(sDebitMediaNo));
                  // Treat EBT like debit.
                  bWasDebit := ((CurSaleData^.Number = StrToInt(sDebitMediaNo)) or
                                (CurSaleData^.Number = StrToInt(sEBTFSMediaNo)) or
                                (CurSaleData^.Number = StrToInt(sEBTCBMediaNo))    );
                  //...53o
                  if (VoidPriorCredit(nOldTransNo, CurSaleData^.ExtPrice, VoidCardNo, bWasDebit)) then
                    begin
                      bCreditVoided := True;
                      // (todo) - Need to adjust DB for shift, dept., etc. amounts.  Credit server already adjusted its tables.
                      New(ReceiptData);
                      ReceiptData^ := CurSaleData^;
                      ReceiptData^.receipttext := CurSaleData^.receipttext;
                      ReceiptData^.SeqNumber    := CurSaleList.Count + 1;
                      ReceiptData^.ExtPrice     := - ReceiptData^.ExtPrice;
                      CurSaleData^.SaleType     := 'Void';       {Sale, Void, Rtrn, VdVd, VdRt}
                      ReceiptData^.CCPrintLine1 := sCCPrintLine1;
                      ReceiptData^.CCPrintLine2 := sCCPrintLine2;
                      ReceiptData^.CCPrintLine3 := sCCPrintLine3;
                      //lk1...
                      ReceiptData^.CCPrintLine4 := sCCPrintLine4;  //20060628c  (correct typo - was "...Line3..."
                      //53o...
//                      ReceiptData^.CCBalance1 := 0.0;
//                      ReceiptData^.CCBalance1 := 0.0;
                      ReceiptData^.CCBalance1 := nCCBalance1;
                      ReceiptData^.CCBalance2 := nCCBalance2;
                      ReceiptData^.CCBalance3 := nCCBalance3;
                      ReceiptData^.CCBalance4 := nCCBalance4;
                      ReceiptData^.CCBalance5 := nCCBalance5;
                      ReceiptData^.CCBalance6 := nCCBalance6;
                      //...53o
                      //...lk1
                      ReceiptData^.CCAuthorizer := nCCAuthorizer;
                      //bph...
                      ReceiptData^.CCRequestType := RT_PURCHASE_REVERSE;
                      ReceiptData^.ActivationState := asActivationDoesNotApply;
                      ReceiptData^.ActivationTimeout := 0;
                      ReceiptData^.ActivationTransNo := 0;
                      ReceiptData^.LineID := GetLineID();
                      ReceiptData^.ccPIN := '';
                      // Decrement media totals in DB
                      RepeatCount := 1;
                      while True do
                        begin
                          try
                            POSDataMod.PosPostCur.StartTransaction;
                            //lk1...
//                            PostSaleData := ReceiptData;  // pointer used by MediaUpdate().
//                            MediaUpdate();
                            if (not DBUpdateMedia(ReceiptData)) then abort;
                            //...lk1
                            POSDataMod.PosPostCur.Commit;
                            break;
                          except
                            on E : Exception do
                              begin
                                UpdateExceptLog( 'Rollback Purchase Reverse ' + IntToStr(RepeatCount) + ' ' + e.message);
                                if POSDataMod.PosPostCur.Transaction.InTransaction then
                                    POSDataMod.PosPostCur.Rollback;
                                sleep(100);
                                Inc(RepeatCount);
                                if RepeatCount > 100 then
                                  begin
                                    // need to log that this happened
                                    break;
                                  end;
                               end;
                          end;  // try/except
                        end;  // while true
                      //...bph
                      CurSaleList.Capacity := CurSaleList.Count;
                      CurSaleList.Add(ReceiptData);
                    end;
                end;
            end;  // for each item in sales list
        end;
      {$ENDIF}
      If ((sKeyType = 'ENT') or (sKeyType = 'PFL') or bCreditVoided) Then
     { All that is left is to print the receipt }
        Begin
          Begin
            rcptSale.nTransNo   := nOldTransNo;                                      //20070618a
            if (bCreditVoided) then PrintReversal()
                               else PrintReprint();
//...bp
            EmptyReceiptList;
            {$IFDEF FF_PROMO}  //20080128a...
            FuelFirstCouponAuthID := 0;  // Will be reset if Fuel First award located below.
            {$ENDIF}  //...20080128a
            for ndx := 0 to (CurSaleList.Count - 1) do
            begin
              New(ReceiptData);
              SD := CurSaleList.Items[ndx];
              ReceiptData^ := SD^;
              ReceiptData^.receipttext := sd^.receipttext;
              ReceiptList.Capacity := ReceiptList.Count;
              ReceiptList.Add(ReceiptData);
              {$IFDEF FF_PROMO}  //20080128a...
              // Check for Fuel First promotion:
              if ((SD^.LineType = 'FUL') and
                  (SD^.SaleType <> 'Void') and
                  (not SD^.LineVoided) and
                  (SD^.CCAuthID > 0)) then
              begin
                FFCouponCount := 0;
                try
                  POSPrt.PrintFuelFirstCoupon(SD^.CCAuthID, False, FFCouponCount);
                except
                  FFCouponCount := 0;
                end;
                if (FFCouponCount > 0) then
                  FuelFirstCouponAuthID := SD^.CCAuthID;  // (note) - Only one FF award (last in sales list) is printed below.
              end;
              {$ENDIF}  //...20080128a
            end;
            rcptSale.nFSSubtotal := curSale.nFSSubtotal;
            rcptSale.nSubtotal  := curSale.nSubtotal;
            rcptSale.nTlTax     := curSale.nTlTax;
            rcptSale.nTotal     := curSale.nTotal;
            rcptSale.nChangeDue := curSale.nChangeDue;
            rcptSale.bSalesTaxXcpt   := curSale.bSalesTaxXcpt;
            //20070618a            rcptSale.nTransNo   := nOldTransNo;
            nRcptShiftNo   := nShiftNo;
            DisposeSalesListItems(CurSaleList);
            if sKeyType = 'ENT' then
              if bXMDActive then
                PrintReceiptNoXMD(ReceiptList)
              else
                PrintReceiptFromReceiptList(ReceiptList)
            else
              PrintFuelOnlyReceiptFromReceiptList(ReceiptList);
            //bpi...
            // Print second copy of reversal receipt.
            if (bCreditVoided) then
              begin
                CCSecond := True;
                PrintReversal();
                if sKeyType = 'ENT' then
                  PrintReceiptFromReceiptList(ReceiptList)
                else
                  PrintFuelOnlyReceiptFromReceiptList(ReceiptList);
              end;
            //...bpi
            {$IFDEF FF_PROMO}  //20080128a...
            // Print any Fuel First promotion award identified above:
            if (FuelFirstCouponAuthID > 0) then
            begin
              try
                POSPrt.PrintFuelFirstCoupon(FuelFirstCouponAuthID, True, FFCouponCount);
              except
              end;
            end;
            {$ENDIF}  //...20080128a
            EmptyReceiptList;
          End;
        End;
      PRINT_OLD_RECEIPT := False;
      If lSuspend.Tag = 0 Then
        lSuspend.Visible := False;
      lSuspend.Caption  := 'Suspended Sale';

      StatusBar1.Panels.Items[1].Text := 'Trans# ';
      lTotal.Caption := 'Total';
      lTotal.Visible := True;
      eTotal.Text := '';
      eTotal.Visible := True;
      //bph...
//      nCurFSSubtotal := 0;
//      nCurSubtotal := 0;
//      nCurTlTax := 0;
//      nCurTotal := 0;
//      nCurAmountDue := 0;
//      nCurChangeDue := 0;
//
//      nCurTransNo := 0;
//      CurSalelist.Clear;
//
//
//      POSListBox.Clear;
      // If any authorizations were voided above, then record new transaction in receipt table
      // and start up another transaction waiting to be re-tendered;
      // otherwise, this was just a re-print of a receipt, so clear the sales list.
      if (bCreditVoided) then
        begin
          AssignTransNo();
          PostSaleList.Clear;
          PostSaleList.Capacity := PostSaleList.Count;
          for ndx := 0 to (CurSaleList.Count - 1) do
            begin
              New(ReceiptData);
              SD := CurSaleList.Items[ndx];
              // Mark department items so that they will not be re-totaled in the database.
              if (SD^.LineType <> 'MED') then
                  SD^.CCRequestType := RT_PURCHASE_REVERSE;
              ReceiptData^ := SD^;
              ReceiptData^.receipttext := sd^.receipttext;
              PostSaleList.Capacity := PostSaleList.Count;
              PostSaleList.Add(ReceiptData);
            end;
          pstSale.nFSSubtotal := curSale.nFSSubtotal;
          pstSale.nSubtotal   := curSale.nSubtotal;
          pstSale.nTlTax      := curSale.nTlTax;
          pstSale.nTotal      := curSale.nTotal;
          pstSale.nAmountDue  := curSale.nAmountDue;
          pstSale.nChangeDue  := curSale.nChangeDue;
          pstSale.nTransNo    := curSale.nTransNo;
          Receipt.SaveSale(PostSaleList);
          POSLog.LogSale(PostSaleList);
          PostSaleList.Clear;
          PostSaleList.Capacity := PostSaleList.Count;
          ReDisplayVoidedCreditSale();
        end
      else
        begin
          curSale.nFSSubtotal := 0;
          curSale.nFuelSubtotal := 0;
          curSale.nSubtotal := 0;
          curSale.nTlTax := 0;
          curSale.bSalesTaxXcpt := False;
          curSale.nTotal := 0;
          curSale.nAmountDue := 0;
          curSale.nChangeDue := 0;
          curSale.nTransNo := 0;
          CurSalelist.Clear;
          CurSalelist.Capacity := CurSalelist.Count;
          POSListBox.Clear;
        end;
      //...bph

      nCurMenu := 0;
      DisposeSalesListItems(CurSaleList);
      DisplayMenu(nCurMenu);

      fmPOS.Refresh;

    End;

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyMNU
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyMNU(const sKeyVal : string);
begin

  nCurMenu := StrToInt(sKeyVal);

  DisplayMenu(nCurMenu);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCLK
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCLK;
begin
  fmClockInOut := TfmClockInOut.Create(self);
  fmClockInOut.ShowModal;
  fmClockInOut.Release;
end;

procedure TfmPOS.ProcessKeyCKN;
var
  DayId : integer;
begin
    POSDataMod.IBRptTrans.StartTransaction;
    DayId := POSDataMod.GetDayId(POSDataMod.IBRptTrans);
    POSDataMod.IBRptTrans.Commit;

    sendMCPMessage(BuildTag(TAG_MSGTYPE, IntToStr(MCP_RUN_CHECKIN))
                   + BuildTag(IntToStr(MCP_DAYID), IntToStr(DayId)));
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyNUM
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyNUM(const sKeyVal : string);
begin
  if length(trim(DisplayEntry.Text)) < 15 then
    begin
      sEntry := sEntry + sKeyVal;
      DisplayEntry.Text := format('%15s',[sEntry]);
      Self.InjLog(Format('ProcessKeyNUM - sEntry="%s"',[sEntry]));
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPMP
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPMP(const sKeyVal : string; const sKeyPreset : string);
begin

  sPumpNo := sKeyVal;

  If (StrToInt(SPumpNo) <= NO_PUMPS) Then
   Begin
    SelPumpIcon :=  nPumpIcons[StrToInt(sPumpNo)];
    SelPumpIcon.Sound := 0;

    bSkipOneKey := True;
    Self.InjLog(Format('ProcessKeyPMP - sPumpNo="%s"',[sPumpNo]));
   End;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyTAX
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyTAX();
begin

  curSale.bSalesTaxXcpt := NOT(curSale.bSalesTaxXcpt);
  ComputeSaleTotal;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCFP
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCFP();
Begin

  fmChangeFuelPrice.Visible := False;

  if fmChangeFuelPrice.ShowModal = mrOK then
    if fmPOSErrorMsg.YesNo('POS Confirm', 'Send Fuel Prices Now') = mrOk then
    begin
      if not POSDataMod.IBFuelPriceChangeTransaction.InTransaction then
        POSDataMod.IBFuelPriceChangeTransaction.StartTransaction;
      with POSDataMod.IBFuelPriceChangeQuery do
      begin
        Close; SQL.Clear;
        SQL.Add(' insert into fuelpricechangelog (ts, productname, cashprice, creditprice, totalvolume, totalvalue, posted)');
        SQL.Add(' select cast(''NOW'' as timestamp),  g.name,  fpc.cashprice,  0,  g.TLVOL,  g.TLAMOUNT,  0');
        SQL.Add(' from grade g, fuelpricechange fpc where fpc.gradeno = g.gradeno');
        ExecSQL;

        Close;SQL.Clear;
        SQL.Add('Update Grade G set CashPrice = (Select CashPrice from FuelPriceChange where GradeNo = G.GradeNo)');
        ExecSQL;
      end;
      if POSDataMod.IBFuelPriceChangeTransaction.InTransaction then
        POSDataMod.IBFuelPriceChangeTransaction.Commit;
      ProcessKeySP1;
    end;
  try
    FFPCPostThread.Resume;
  except
    on E: Exception do
    begin
      UpdateExceptLog('Failed to resume FPC thread after sending prices - restarting - %s: %s', [E.ClassName, E.Message]);
      try
        StartFPCThread;
        FFPCPostThread.Resume;
      except
        UpdateExceptLog('Failed to resume FPC thread after restarting - ignoring - %s: %s', [E.ClassName, E.Message]);
      end;
    end;
  end;
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyRPD
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyRPD ();  {Pump Off Line}
var
pNo : integer;
Begin
  //20060531...
  if sPumpNo = '' then    //Capture empty string
    pNo := 0
  else
  //...20060531
    try
      pNo := StrToInt(sPumpNo);
    except
      pNo := 0;
    end;
  if (pNo > 0) and (pNo <= NO_PUMPS) then
    begin
      fmPOS.SendFuelMessage( pNo, PMP_OFFLINE, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP )
    end;
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyRPE
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyRPE ();  {Pump On Line}
var
pNo : integer;
Begin
  //20060531...
  if sPumpNo = '' then    //Capture empty string
    pNo := 0
  else
  //...20060531
    try
      pNo := StrToInt(sPumpNo);
    except
      pNo := 0;
    end;
  if (pNo > 0) and (pNo <= NO_PUMPS) then
    begin
      fmPOS.SendFuelMessage( pNo, PMP_ONLINE, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP )
    end;

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyRPF
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyRPF ();  {Pump All Auth}
var
  pNo :short;
begin

  for pNo := 1 to No_Pumps do
    begin
      SendFuelMessage( pNo, PMP_FORCEAUTH, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
    end;

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeySP1
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeySP1();
var
  bClosePOSMsg: Boolean;
Begin

  bClosePOSMsg := Not(fmPOSMsg.Visible);

  ReportToDisk := True;
  LogReportMarker('^^^FPC ' + FormatDateTime('mmm d,yyyy hh:mm AM/PM', Now() ));
  FuelTotalsReport(False);
  LogReportMarker('^^^END');
  ReportToDisk := False;


  fmPOSMsg.ShowMsg('Downloading Fuel Prices...', '');
  // Send Prices to Pumps
  SendFuelMessage( 0, PMP_SETPRICES, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );

  // Write New Prices and Closing Totals to FuelPrice Table
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close; SQL.Clear;
    SQL.Add('Insert Into FuelPrice (GradeNo, QtyClose, CashClose, CreditClose, NewPrice, DateRead, TimeRead) ');
    SQL.Add('Select PD.GradeNo, Sum(PT.VolumeTl) QtyClose, ');
    SQL.Add('Sum(PT.CashTl) CashClose, Sum(PT.CreditTl) CreditClose, ');
    SQL.Add('Min(G.CashPrice) NewPrice, Min(PT.DateTimeRead) DateRead, Min(PT.DateTimeRead) TimeRead ');
    SQL.Add('From (PumpDef PD Join PumpTls PT On ((PT.TlNo = :pTlNo) And ');
    SQL.Add('(PD.PumpNo = PT.PumpNo) And (PD.HoseNo = PT.HoseNo))) ');
    SQL.Add('Join Grade G On (PD.GradeNo = G.GradeNo) ');
    SQL.Add('Group By PD.GradeNo');

    ParamByName('pTlNo').AsInteger := nFuelTotalID;
    ExecSQL;
    Close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  if bClosePOSMsg then fmPOSMsg.Close;
  nFuelTotalID := 0;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPAT
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPAT();
var
  pNo :short;
begin

  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      SendFuelMessage( pNo, PMP_AUTHORIZE, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
      //Build 23
      sPumpNo := '';
      //Build 23
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPST
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPST();
var
  pNo :short;
begin

  if sEntry = '' then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;

  nAmount := StrToFloat(sEntry);
  if not (nAmount > 0) then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;

  nAmount := nAmount / 100 ;
  if (nAmount > 200) then
    begin
      POSError('Over High Amount Limit');
      Exit;
    end;

  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      SendFuelMessage( pNo, PMP_AUTHORIZE, nAmount, NOSALEID, NOTRANSNO, NODESTPUMP );
      //Build 23
      sPumpNo := '';
      //Build 23
    end;
  ClearEntryField;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPAL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPAL();
begin
  SendFuelMessage( 1, PMP_AUTHALL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPDA
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPDA();
var
  pNo :short;
begin

  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      SelPumpIcon :=  nPumpIcons[pNo];
      If Not(SelPumpIcon.Frame in [FR_VISA, FR_VISAAUTH,
                                   FR_MC, FR_MCAUTH,
                                   FR_DISC, FR_DISCAUTH,
                                   FR_AMEX, FR_AMEXAUTH,
                                   FR_FLEETONE, FR_FLEETONEAUTH,
                                   FR_VOYAGER, FR_VOYAGERAUTH,
                                   FR_WEX, FR_WEXAUTH,
                                   FR_GIFT, FR_GIFTAUTH,
                                   {$IFDEF FUEL_FIRST}
                                   FR_FUELFIRST, FR_FUELFIRSTAUTH,
                                   {$ENDIF}
                                   {$IFDEF PUMP_ICON_EXT}
                                   {$IFDEF FF_PROMO}
                                    FR_FUELFIRST_AUTH_WIN,
                                    FR_FLOWSTARTFUELFIRST_WIN, FR_FLOWENDFUELFIRST_WIN,
                                    {$ENDIF}  // FF_PROMO
                                    FR_FLOWSTARTFUELFIRST, FR_FLOWENDFUELFIRST,
                                   {$ENDIF}  // PUMP_ICON_EXT
                                   FR_DINERS, FR_DINERSAUTH   ]) Then       // No Deauth on CAT Sales...
         SendFuelMessage( pNo, PMP_DEAUTH, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
      //Build 23
      sPumpNo := '';
      //Build 23
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPPY
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPPY();
var
pNo :short;
ppyGradeNo,
ndx : byte;
ppyDeptNo : integer;
begin

  if sEntry = '' then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;

  nAmount := StrToFloat(sEntry);
  if not (nAmount > 0) then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;

  nAmount := nAmount / 100 ;
  if (nAmount >= 1000) then
    begin
      POSError('Over High Amount Limit');
      Exit;
    end;

  if sPumpNo = '' then
    begin
      POSError('Please Select A Pump');
      ClearEntryField;
      Exit;
    end;
  pNo := StrToInt(sPumpNo);
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from PumpDef where PumpNo = :pPumpNo');
    parambyname('pPumpNo').AsInteger := pNo;
    open;
    while not eof do //Gets to the last record to make sure we only deal with single hose/product dispensers
      next;
    if recordcount = 1 then
    begin
      ppyGradeNo := fieldbyname('GradeNo').AsInteger;
      close;SQL.Clear;
      SQL.Add('Select * from Grade where GradeNo = :pGradeNo');
      parambyname('pGradeNo').AsInteger := ppyGradeNo;
      open;
      if Recordcount > 0 then
        ppyDeptNo := fieldbyname('DeptNo').AsInteger
      else
        ppyDeptNo := 0;
      close;
    end
    else
      ppyDeptNo := 0;
    if ppyDeptNo <> 0 then
    begin
      SQL.Clear;
      SQL.Add('SELECT * FROM POPUPMSG where MsgDepartment = :pMsgDepartment');
      parambyname('pMsgDepartment').AsString := inttostr(ppyDeptNo);
      open;
      if recordcount > 0 then
      begin
        InitPopUpMsgRecord;
        PopUpMsg^.MsgType   := FieldByName('MsgType').AsInteger;
        PopUpMsg^.MsgTime   := 0;
        PopUpMsg^.MsgHeader := FieldByName('MsgHeader').AsString;
        for ndx := 1 to 10 do
        begin
          PopUpMsg^.MsgLine[ndx] := FieldByName('MsgLine'+ IntToStr(ndx)).AsString;
        end;
        PopUpMsgList.Capacity := PopUpMsgList.Count;
        PopUpMsgList.Add(PopUpMsg);
        fmPopUpMsg.ShowModal;
      end;
      close;
    end;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  SendFuelMessage( pNo, PMP_RESERVE, nAmount, NOSALEID, NOTRANSNO, NODESTPUMP );
  //Build 23
  sPumpNo := '';
  //Build 23
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPPR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPPR();
var
  CloseStart : TDateTime;
begin
  if (PPTrans <> nil) then
  begin
    fmPOSMsg.ShowMsg('Initializing PIN Pad...', '');
   // PPTrans.SendReBoot();
    PPTrans.PINPadReBoot();
    PPTrans.PinPadTransReset();
    PPTrans.PinPadClose();
    CloseStart := Now();
    while (not TimerExpired(CloseStart,5)) do
    begin
      if not PPTrans.PinPadOnLine then break; // written this way intentionally.  if PinPadOnLine is in while condition, it gets evaluated once.
      Application.ProcessMessages;
      sleep(20);
    end;
    if not PPTrans.PinPadOnLine then
      SetupDevice(7);
    fmPOSMsg.Close();
      end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PostPrePay
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TWMPostPrePay
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.PostPrePay(var Msg: TWMPostPrePay);
var
PumpNo       : integer;
HoseNo       : integer;
SaleID       : integer;
SaleVolume   : currency;
SaleAmount   : currency;
PrePayAmount : currency;
begin

  PumpNo       := Msg.PostPrePayInfo.PumpNo;
  HoseNo       := Msg.PostPrePayInfo.HoseNo;
  SaleID       := Msg.PostPrePayInfo.SaleID;
  SaleVolume   := Msg.PostPrePayInfo.SaleVolume;
  SaleAmount   := Msg.PostPrePayInfo.SaleAmount;
  PrePayAmount := Msg.PostPrePayInfo.PrePayAmount;
  Dispose(Msg.PostPrePayInfo);
  PostPrePaytoDB(PumpNo, HoseNo, SaleID, SaleVolume, SaleAmount, PrePayAmount);

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessPrePay
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TWMProcessPrePay
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessPrePay(var Msg: TWMProcessPrePay);
var
  PumpNo : integer;
  PrePayAmount : currency ;
  SD : pSalesData;
begin

  PumpNo := Msg.ProcessPrePayInfo.PumpNo;
  PrePayAmount := Msg.ProcessPrePayInfo.PrePayAmount;
  Dispose(Msg.ProcessPrePayInfo);

  if SaleState = ssNoSale then
    AssignTransNo;

  nPumpNo := PumpNo;
  nAmount := PrePayAmount;

  nPumpAmount := PrePayAmount;
  nPumpVolume := 0;
  nPumpSaleID := 0;

  nQty       := 1;
  SaleState  := ssSale;
  sLineType  := 'PPY';
  sSaleType  := 'Sale';

  SD := AddSaleList;

  PoleMdse(SD, SaleState);

  ComputeSaleTotal;
  ClearEntryField;
  nPumpNo := 0;

  if assigned(Self.InjectionPort) and Self.InjectionPort.Open then
  try
    Self.InjectionPort.PutString(#02 + 'BTN' + #30 + 'PPY' + #30 + IntToStr(PumpNo) + #03);
  except
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPSL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPSL();
var
  pNo : short;
begin

  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      {see if the server will allow this sale to be collected}
      SendFuelMessage( pNo, PMP_COLLECTASK, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
      //Build 23
      sPumpNo := '';
      //Build 23
    end
  else
    begin
      POSError('Please Select A Pump');
      Exit;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPHL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPHL();
var
pNo : short;
begin

  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      SendFuelMessage( pNo, PMP_STOP, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);
      //Build 23
      sPumpNo := '';
      //Build 23
    end
  else
    begin
      POSError('Please Select A Pump');
      Exit;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyEHL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyEHL();
begin

  SendFuelMessage(0, PMP_ALLSTOP, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPRS
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPRS();
var
pNo : short;
begin

  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      SendFuelMessage(pNo, PMP_RESUME, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);
      //Build 23
      sPumpNo := '';
      //Build 23
    end
  else
    begin
      POSError('Please Select A Pump');
      Exit;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyNSL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyNSL();
begin
  OpenDrawer;
  dTillOpenTime := Now;
  AssignTransNo;
  PostNoSale(ThisTerminalNo, nShiftNo);
  LogNoSale;
  if bCompulseDwr then
  begin
    CloseDrawer;
    if nTillTimer > 0 then  // if a till timeout is defined
    begin
      if TimerExpired(dTillOpenTime, nTillTimer) then
      begin
        IncrementTillTimeout(dTillOpenTime, nTillTimer);
      end;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCNL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCNL();
var
  ndx : short;
    //20020205...
  GiftCardsActivated : boolean;
  gd : pGiftCardData;
    //...20020205
  SD : pSalesData;

begin
    //20020205...
//  if bGiftFailed then
  // If any gift cards were activated with a credit media that failed,
  // then do not allow the sale to be canceled.
  GiftCardsActivated := False;
  for ndx := 0 to qClient^.GiftCardActivateList.Count - 1 do
    begin
      gd := qClient^.GiftCardActivateList.Items[ndx];
      if ((gd^.CardStatus = CS_JUST_ACTIVATED) or (gd^.CardStatus = CS_JUST_RECHARGED)) then
        begin
          GiftCardsActivated := True;
          break;
        end;
    end;
  if ((qClient^.bCreditAuthFailed) and GiftCardsActivated) then
    //...20020205
  begin
    POSError('Cannot Cancel with Gift Card Pending');
    exit;
  end;
  //bph...

  // Verify that a "re-tender" is not in progress.  A retender cannot be canceled.
  for Ndx := 0 to (CurSaleList.Count - 1) do
    begin
      SD := CurSaleList.Items[Ndx];
      if (SD^.CCRequestType = RT_PURCHASE_REVERSE) then
        begin
          POSError('Cannot Cancel after Purchase Reverse');
          exit;
        end;
    end;
  //...bph
  pstSale.nTransNo := curSale.nTransNo;

  PostCancel(CurSaleList, curSale.nTransNo, Self.ThisTerminalNo, nShiftNo, curSale.nTotal);
  LogCancel;
  bSaleComplete := True;

  // Let pin pad know that transaction is cancelled
  if (PPTrans <> nil) then
    PPTrans.TransNo := 0;

  if CurSaleList.Count > 0 then
    DisposeSalesListItems(CurSaleList);
  CurSaleList.Pack;
  InitScreen;
  ClearEntryField;
  nTimercount := 95;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyUP
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyUP();
begin
  if SaleState = ssSale then
    begin
      if POSListBox.ItemIndex > 0 then
        POSListBox.ItemIndex := POSListBox.ItemIndex - 1;
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyDN
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyDN();
begin
  if SaleState = ssSale then
    begin
      if POSListBox.ItemIndex < POSListBox.Items.Count - 1 then
        POSListBox.ItemIndex := POSListBox.ItemIndex + 1;
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeySR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeySR();
var
  nNdx: byte;
  RetVal , AutoCancel : boolean;
//bpj...
//begin
  bReTendering : boolean;
  SD : pSalesData;
  j : integer;
begin

  // Determine if this is a resume or suspend operation.
//...bpj
  RetVal := False;
  if bSuspendedSale then
    begin
    if SaleState = ssNoSale then
      begin
        AutoCancel := False;
        lSuspend.Visible := False;
        lSuspend.Tag := 0;
        RecallSale;
        AssignTransNo;
        SaleState := ssSale;
        //bpj...
        bRetendering := False;   // initial assumption
        //...bpj
        for nNdx := 0 to (CurSaleList.Count - 1) do
          begin
            SD := CurSaleList.Items[nNdx];

            //bpj...
//            if (CurSaleData^.LineType = 'FUL') and
            if (SD^.CCRequestType = RT_PURCHASE_REVERSE) then
                bRetendering := True;
            if (SD^.CCRequestType <> RT_PURCHASE_REVERSE) and
               (SD^.LineType = 'FUL') and
            //...bpj
                    (SD^.SaleType = 'Sale') and
                            (SD^.LineVoided = False) then
              begin
                case nFuelInterfaceType of
                1,2 : RetVal := False; //DCOMFuelProg.ValidFuelSale(ThisTerminalNo, SD^.PumpNo, SD^.FuelSaleID );
                end;
                if NOT RetVal then AutoCancel := True;

              end;
            // Check to see if an activating product received a decline from the credit server
            // while the sale was suspended.  If so, then it must be error corrected.
            if ((SD^.ActivationState in [asActivationDeclined,
                                                  asActivationFailed,
                                                  asActivationApproved,
                                                  asActivationRejected]) and
                (SD^.SaleType = 'Rtrn') and (not SD^.LineVoided)) then
            begin
              if (SD^.ActivationState <> asActivationApproved) then
                fmPOS.POSError('De-Activation Declined While Suspended');
              PostMessage(fmPOS.Handle, WM_ACTIVATION_RESPONDED, 0, LongInt(0));
            end;
            PoleMdse(SD, SaleState);
          end;
        // If pin pad configured, then update the display.
        for j := max(0, CurSaleList.Count - 1 - PPTrans.ReceiptLines) to CurSaleList.Count - 1 do
          DisplaySaleDataToPinPad(PPTrans, CurSaleList.Items[j]);

        //bpj...
        if (bRetendering) then
            SaleState := ssTender;   // Additional items cannot be added to sales list.
        //...bpj
        ComputeSaleTotal;
        if AutoCancel then
          begin
            ProcessKeyCNL;
            POSError('Sale Cancelled - Fuel Sale Error');
          end;
      end;
    end
  else if CurSaleList.Count > 0 then
    begin
      //bpj...
//      if SaleState = ssSale then

      // Determine if this sale is being re-tendered.
      bRetendering := False;           // Initial assumption.
      for nNdx := 0 to (CurSaleList.Count - 1) do
        begin
          SD := CurSaleList.Items[nNdx];
          if (SD^.CCRequestType = RT_PURCHASE_REVERSE) then
            begin
              bRetendering := True;
              break;
            end;
        end;

      // Verify that sale can be suspended.
      if ((SaleState = ssSale) or (bRetendering and (SaleState = ssTender))) then
      //...bpj
        begin
          pstSale.nTransNo := curSale.nTransNo;
          LogSuspend;
          SuspendSale;
          // Let pin pad know that transaction is suspended
          if (PPTrans <> nil) then
            PPTrans.TransNo := 0;
          InitScreen;
          CurSaleList.Clear;
          CurSalelist.Capacity := CurSalelist.Count;
          nTimerCount := 95;
          lSuspend.Visible := True;
          lSuspend.Tag := 1;
        end;
    end;

end;



//20070501a...
function TfmPOS.BuildKioskConnectionString : string;
var
  DBName,
  DBSource,
  DBUserName,
  DBPassword : string;
begin
  if not POSDataMod.IBKioskTrans.InTransaction then
    POSDataMod.IBKioskTrans.StartTransaction;
  with POSDataMod.IBQryKiosk do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from Kiosk');
    Open;
    DBName := FieldByName('DBName').AsString;
    DBSource := FieldByName('DBSource').AsString;
    DBUserName := FieldByName('DBUserName').AsString;
    DBPassword := FieldByName('DBPassWord').AsString;
    Close;
  end;
  if POSDataMod.IBKioskTrans.InTransaction then
    POSDataMod.IBKioskTrans.Commit;
  BuildKioskConnectionString := 'Provider=SQLOLEDB;Initial Catalog=' + DBName + ';Data Source=' + DBSource + ';UID=' + DBUserName + ';Pwd=' + DBPassword;
end;  // function BuildKioskConnectionString
//...20070501a

procedure TfmPOS.AddSalesListBeforeMedia(const AddSalesData : pSalesData);
var
  qSalesData : pSalesData;
  InsertIndex : integer;
  NextSeqNumber : integer;
  j : integer;
begin
  {
  If this item is being added post tender (such as for an auto-void of an
  activation product), then add the new item before the media lines (resequencing
  lines that follow); otherwise, just add the entry to the end of the list.
  }
  InsertIndex := -1;
  NextSeqNumber := -1;
  for j := 0 to CurSaleList.Count - 1 do
  begin
    qSalesData := CurSaleList.Items[j];
    if (((qSalesData^.LineType = 'MED') or (qSalesData^.LineType = 'TAX')) and (not qSalesData^.LineVoided)) then
    begin
      InsertIndex := j;
      NextSeqNumber := qSalesData^.SeqNumber;
      break;
    end;
  end;
  if (InsertIndex >= 0) then
  begin
    CurSaleList.Insert(InsertIndex, AddSalesData);
    for j := InsertIndex to CurSaleList.Count - 1 do
    begin
      qSalesData := CurSaleList.Items[j];
      qSalesData^.SeqNumber := NextSeqNumber;
      Inc(NextSeqNumber);
    end;
  end
  else
  begin
    CurSaleList.Add(AddSalesData);
  end;
end;  // procedure AddSalesListBeforeMedia

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcesskeyKSL
  Author:    Gary Whetton
  Date:      04-Jun-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcesskeyKSL;
  //20070501a...
//begin
//  if bKioskActive then
//  begin
//    if Length(sEntry) > 0 then
//    begin
//      //20060922a...
//      if (Copy(sEntry,1,1) = '8') and (length(sEntry) = 13) then
//      begin
//        {$IFDEF UPC_EXPAND}
//        if sEntry <> ValidateUPCCheckDigit(sEntry,sEntry) then
//        begin
//        {$ENDIF}
//          sEntry := copy(sEntry,2,length(sEntry)-2);
//      //...20060922a
//          try
//            KioskOrderNo := strtoint(sEntry);
//          except
//            sEntry := '';
//          end;
//          case KioskFrame.GetKioskSale of
//            0 : POSError('Order Not Found');
//            2 : POSError('Order Paid');
//          end;
//        {$IFDEF UPC_EXPAND}
//        end
//        else
//        begin
//    //20060922a...
//          sEntry := '';
//          POSError('Order Not Found');
//        end;
//        {$ENDIF}
//      end
//      else
//      begin
//        sEntry := '';
//        POSError('Order Not Found');
//      end;
//    end
//    else
//    begin
//    //...20060922a
//      if sEntry = '' then
//      begin
//        fmKiosk.Caption := 'Scan or Enter Kiosk Barcode Number';  //20060922a ('Order' changed to 'Barcode')
//        fmKiosk.Show;
//      end
//      else
//        fmKiosk.Visible := False;
//      while fmKiosk.Visible = True do
//      begin
//        Application.ProcessMessages;
//        sleep(20);
//      end;
//      if Length(fmKiosk.fldKioskCode.Text) > 0 then
//      begin
//        //20060922a...
////        KioskOrderNo := strtoint(fmKiosk.fldKioskCode.Text);
//        if (Copy(fmKiosk.fldKioskCode.Text,1,1) = '8') and (length(fmKiosk.fldKioskCode.Text) = 13) then
//        begin
//          {$IFDEF UPC_EXPAND}
//          if fmKiosk.fldKioskCode.Text <> ValidateUPCCheckDigit(fmKiosk.fldKioskCode.Text,fmKiosk.fldKioskCode.Text) then
//          begin
//          {$ENDIF}
//            sEntry := copy(fmKiosk.fldKioskCode.Text,2,length(fmKiosk.fldKioskCode.Text)-2);
//            try
//              KioskOrderNo := strtoint(sEntry);
//            except
//              sEntry := '';
//            end;
//            KioskOrderNo := strtoint(sEntry);
//            //...20060922a
//            fmKiosk.fldKioskCode.Text := '';
//            case KioskFrame.GetKioskSale of
//              0 : POSError('Order Not Found');
//              2 : POSError('Order Paid');
//            end;
//            //20060922a...
////        //if not KioskFrame.GetKioskSale then
////        //  POSError('Order Not Found');
//          {$IFDEF UPC_EXPAND}
//          end
//          else
//            POSError('Order Not Found');
//          {$ENDIF}
//        end
//        else
//          POSError('Order Not Found');
//        //...20060922a
//      end
//      else if Length(sEntry) > 0 then
//      begin
//        //20060922a...
////        KioskOrderNo := strtoint(fmKiosk.fldKioskCode.Text);
//        if (Copy(sEntry,1,1) = '8') and (length(sEntry) = 13) then
//        begin
//          {$IFDEF UPC_EXPAND}
//          if sEntry <> ValidateUPCCheckDigit(sEntry,sEntry) then
//          begin
//          {$ENDIF}
//            sEntry := copy(sEntry,2,length(sEntry)-2);
//            try
//              KioskOrderNo := strtoint(sEntry);
//            except
//              sEntry := '';
//            end;
//            KioskOrderNo := strtoint(sEntry);
//            //...20060922a
//            sEntry := '';
//            case KioskFrame.GetKioskSale of
//              0 : POSError('Order Not Found');
//              2 : POSError('Order Paid');
//            end;
//            //20060922a...
////        //if not KioskFrame.GetKioskSale then
////          //POSError('Order Not Found');
//          {$IFDEF UPC_EXPAND}
//          end
//          else
//            POSError('Order Not Found');
//          {$ENDIF}
//        end
//        else
//          POSError('Order Not Found');
//        //...20060922a
//      end;
//    end;
//  end
//  else
//    POSError('Kiosk not active');

  function ConvertKioskOrderNumber(sEntryNum : string) : string;
  var
    tempOrderInt : integer;

  begin
    tempOrderInt := StrtoInt(sEntryNum);
    if tempOrderInt > 100 then
      ConvertKioskOrderNumber := sEntryNum
    else
    begin
      if bKioskActive then               //20070717b (was KioskFrame.KioskActive)
      begin
        tempOrderInt := tempOrderInt - 1;
        with POSDataMod.KioskOrderQry do
        begin
          Close;SQL.Clear;
          ConnectionString := BuildKioskConnectionString;
          SQL.Add('SELECT MAX(or_id) LastOrder ');
          SQL.Add('FROM tblOrders ');
          SQL.Add('WHERE ((or_id = ' + InttoStr(tempOrderInt) + ') or (or_id%10 = ' + InttoStr(tempOrderInt) + ') or (or_id%100 = ' + InttoStr(tempOrderInt) + ')); ');
          Open;
          if RecordCount > 0 then
          begin
            First;
            tempOrderInt := fieldbyName('LastOrder').AsInteger;
          end;
          Close;
        end;
        ConvertKioskOrderNumber := InttoStr(tempOrderInt);
      end;
    end;
  end;

begin
  //20070322... Consolidate code
  if bKioskActive then
  begin
    fmKiosk.fldKioskCode.Text := '';
    if sEntry = '' then
    begin
      fmKiosk.Caption := 'Scan or Enter Kiosk Barcode or Order Number';
      fmKiosk.Show;
    end
    else
      fmKiosk.Visible := False;
    while fmKiosk.Visible = True do
    begin
      Application.ProcessMessages;
      sleep(20);
    end;
    if ((sEntry = '') and (fmKiosk.fldKioskCode.Text <> '')) then
      sEntry := fmKiosk.fldKioskCode.Text;
    if length(sEntry) > 0 then
    begin
      if (Copy(sEntry,1,1) = '8') and (length(sEntry) = 13) then
      begin
        {$IFDEF UPC_EXPAND}
        if sEntry <> ValidateUPCCheckDigit(sEntry,sEntry) then
        {$ENDIF}
          sEntry := copy(sEntry,2,length(sEntry)-2);
      end
      else
        sEntry := ConvertKioskOrderNumber(sEntry);
      try
        KioskOrderNo := strtoint(sEntry);
      except
        sEntry := '';
      end;
      case KioskFrame.GetKioskSale of
        0 : POSError('Order Not Found');
        2 : POSError('Order Paid');
      end;
    end;
  end
  else
    POSError('Kiosk not active');
  //...20070501a
end;



{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyQTY
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyQTY();
begin

  if sEntry = '' then
    begin
      POSError('Please Enter A Quantity');
      Exit;
    end;

  nQty := StrToInt(sEntry);
  if nQty < 1 then
    begin
      POSError('Please Enter A Quantity');
      nQty := 1;
      Exit;
    end;

  if nQty > 99 then
    begin
      POSError('Quantity Limit Exceeded');
      nQty := 1;
      Exit;
    end;

  DisplayQty.Text := CurrToStr(nQty) + '@';
  DisplayQty.Visible := True;
  sEntry := '';
  DisplayEntry.Text := '';

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyDPT
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyDPT(const sKeyVal : string; const sPreset : string);
var
  nKeyVal : integer;
  ndx : byte;
  SD : pSalesData;
begin

  InitActivationDataForSaleItem(@ActivationProductData);
  try
    nKeyVal := StrToInt(sKeyVal);
  except
    nKeyVal := 0;
  end;
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBDeptQuery do
  begin
    Close;
    ParamByName('pDeptNo').AsInteger := nKeyVal;
    Open;
    if RecordCount = 0 then
    begin
      Close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      POSError('Department Not Found');
      Exit;
    end;
    GetDept(POSDataMod.IBDeptQuery, @Dept);
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;

  if (Setup.MOSystem) and (Dept.DeptName = 'Money Order') then
  begin
    ProcessKeyMOP;
    exit;
  end;

  if sPreset <> '' then
    sEntry := sPreset;

  if sEntry = '' then
  begin
    POSError('Please Enter An Amount');
    Exit;
  end;

  try
    nAmount := StrToFloat(sEntry);
  except
    POSError('Invalid Numeric Entry');
    ClearEntryField;
    Exit;
  end;

  if nAmount = 0 then
  begin
    POSError('Please Enter An Amount');
    Exit;
  end;

  nAmount := nAmount / 100;
  if (Dept.HALO > 0) and
   (nAmount > Dept.HALO) then
  begin
    POSError('Over High Amount Limit');
    Exit;
  end;

  if (Dept.LALO > 0) and
   (nAmount < Dept.LALO) then
  begin
    POSError('Under Low Amount Limit');
    Exit;
  end;

  if Dept.RestrictionCode > 0 then
    if not RestrictionCodeOK(Dept.RestrictionCode) then
      exit;

  if Dept.MaxCount > 0 then
    if not DepartmentMaxCountOK(Dept.DeptNo, Dept.MaxCount) then
      exit;

  if SaleState = ssNoSale then
    AssignTransNo;

  SaleState := ssSale;
  sLineType := 'DPT';

  if Dept.Subtracting then
    nAmount := nAmount * -1;

  if nQty = 0 then
    nQty := 1;

  if lbReturn.Visible = True then
  begin
    sSaleType := 'Rtrn';
    nQty := nQty * -1;
  end
  else
    sSaleType := 'Sale';

  SD := AddSaleList;
  PoleMdse(SD, SaleState);
  ComputeSaleTotal;

  CheckItemForActivation(SD, @ActivationProductData);

  if bCaptureNFPLU then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBNFPLUQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('Insert into NFPlu ( PLUNo, DeptNo, Price) Values (:pPLUNo, :pDeptNo, :pPrice)');
      ParamByName('pPLUNo').AsCurrency := nCaptureNFPLUNumber;
      ParamByName('pDeptNo').AsInteger := StrToInt(sKeyVal);
      ParamByName('pPrice').AsCurrency := nAmount;
      ExecSQL;
      Close;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
    bCaptureNFPLU := False;
  end;

  ClearEntryField;

  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('SELECT * FROM POPUPMSG where MsgDepartment = :pMsgDepartment');
    parambyname('pMsgDepartment').AsString := inttostr(Dept.DeptNo);
    open;
    if recordcount > 0 then
    begin
      InitPopUpMsgRecord;
      PopUpMsg^.MsgType   := FieldByName('MsgType').AsInteger;
      PopUpMsg^.MsgTime   := 0;
      PopUpMsg^.MsgHeader := FieldByName('MsgHeader').AsString;
      for ndx := 1 to 10 do
      begin
        PopUpMsg^.MsgLine[ndx] := FieldByName('MsgLine'+ IntToStr(ndx)).AsString;
      end;
      PopUpMsgList.Capacity := PopUpMsgList.Count;
      PopUpMsgList.Add(PopUpMsg);
      fmPopUpMsg.ShowModal;
    end;
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessFuel
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TWMProcessFuel
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessFuel(var Msg: TWMProcessFuel);
var
  PumpNo, HoseNo, SaleID, DeptNo, GradeNo : integer;
  UnitPrice, SaleVolume, SaleAmount : currency;
  {$IFDEF FUEL_FIRST}
  iAuthID : integer;
  iCardType : integer;
  {$ENDIF}
  {$IFDEF ODOT_VMT}
  VMTFee : currency;
  VMTReceiptData : WideString;
  StateTaxPerGallon : currency;
  DiscountAmount : currency;
  {$ENDIF}
  {$IFDEF FF_PROMO}
  FuelFirstCouponCount : integer;
  {$ENDIF}
//  {$IFDEF FUEL_PRICE_ROLLBACK}
//  cCashPrice : currency;
//  cCreditPrice : currency;
//  cNewAmount : currency;
//  cDiscountAmount : currency;
//  bDisplayAsDiscount : boolean;
//  {$ENDIF}
  ndx : byte;
  SD : pSalesData;
begin

  PumpNo     := Msg.ProcessFuelInfo.PumpNo;
  HoseNo     := Msg.ProcessFuelInfo.HoseNo;
  SaleID     := Msg.ProcessFuelInfo.SaleID;
  UnitPrice  := Msg.ProcessFuelInfo.UnitPrice;
  SaleVolume := Msg.ProcessFuelInfo.SaleVolume;
  SaleAmount := Msg.ProcessFuelInfo.SaleAmount;
  {$IFDEF FUEL_FIRST}
  iAuthID    := Msg.ProcessFuelInfo.AuthID;
  iCardType  := Msg.ProcessFuelInfo.CardType;
  {$ENDIF}
  {$IFDEF ODOT_VMT}
  VMTFee     := Msg.ProcessFuelInfo.VMTFee;
  VMTReceiptData := Msg.ProcessFuelInfo.VMTReceiptData;
  {$ENDIF}

  Dispose(Msg.ProcessFuelInfo);

  if SaleState = ssNoSale then
    AssignTransNo;
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBPumpDefQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from PumpDef where PumpNo = :pPumpNo and HoseNo = :pHoseNo');
      ParamByName('pPumpNo').AsInteger := PumpNo;
      ParamByName('pHoseNo').AsInteger := HoseNo;
      Open;
      if EOF then
      begin
        Close;
        POSError('PumpDef Not Found');
        Exit;
      end;
      GradeNo := FieldByName('GradeNo').AsInteger;
      Close;
    end;
  with POSDataMod.IBGradeQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from Grade where GradeNo  = :pGradeNo');
      ParamByName('pGradeNo').AsInteger := GradeNo;
      Open;
      if EOF then
      begin
        Close;
        POSError('Grade Not Found');
        Exit;
//      {$IFDEF FUEL_PRICE_ROLLBACK}
//      end
//      else
//      begin
//        cCashPrice := FieldByName('CashPrice').AsCurrency;
//        cCreditPrice := FieldByName('CreditPrice').AsCurrency;
//      {$ENDIF}
      end;
      DeptNo := FieldByName('DeptNo').AsInteger;
      {$IFDEF ODOT_VMT}
      StateTaxPerGallon := FieldByName('StateTax').AsCurrency;
      {$ENDIF}
      Close;
    end;

  with POSDataMod.IBDeptQuery do
  begin
    ParamByName('pDeptNo').AsInteger := DeptNo;
    Open;
    if EOF then
    begin
      Close;
      POSError('Department Not Found');
      Exit;
    end;
    GetDept(POSDataMod.IBDeptQuery, @Dept);
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
//  {$IFDEF FUEL_PRICE_ROLLBACK}
//  // Check for a rolled back price (for a discount) at the pump
//   bDisplayAsDiscount := ((cCashPrice > 0.0) and (cCreditPrice > 0.0) and (UnitPrice = cCashPrice) and (cCashPrice < cCreditPrice));
//   if (bDisplayAsDiscount) then
//   begin
//     // Fuel was pumped at lower "cash" price.  Display as if pumped with higher "credit" price,
//     // and include a discount line below so that total is the same:
//     UnitPrice := cCreditPrice;
//     cNewAmount := POSRound(SaleVolume * UnitPrice, 2);
//     cDiscountAmount := cNewAmount - SaleAmount;
//     SaleAmount := cNewAmount;
//   end
//   else
//   begin
//     cDiscountAmount := 0.0;
//   end;
//  {$ENDIF}
  nPumpNo        := PumpNo;
  nAmount        := SaleAmount;
  nPumpAmount    := SaleAmount;
  nPumpVolume    := SaleVolume;
  nPumpSaleID    := SaleID;
  nPumpUnitPrice := UnitPrice;

  SaleState := ssSale;
  sLineType := 'FUL';
  sSaleType := 'Sale';
  {$IFDEF FUEL_FIRST}
  iCATAuthID := iAuthID;
  iCATCardType := iCardType;
  {$ENDIF}
  SD := AddSaleList;
  PoleMdse(SD, SaleState);
  ComputeSaleTotal;
//  {$IFDEF FUEL_PRICE_ROLLBACK}
//  // If price at pump had been rolled back, then also apply discount
//   if (bDisplayAsDiscount) then
//   begin
//      sLineType := 'DS$';
//      sSaleType := 'Sale';    {Sale, Void, Rtrn, VdVd, VdRt}
//      nDiscNo := CASH_FUEL_DISC_NO;
//      nDiscType := 'F';
//      nQty   := 1;
//      nAmount := - cDiscountAmount;
//      AddSaleList();
//      ComputeSaleTotal();
//   end;
//  {$ENDIF}
  {$IFDEF FF_PROMO}
  // Check for Fuel First award.
  try
    POSPrt.PrintFuelFirstCoupon(iAuthID, False, FuelFirstCouponCount);
  except
    FuelFirstCouponCount := 0;
  end;
  if (FuelFirstCouponCount > 0) then
  begin
    sLineType := 'FFP';
    sSaleType := 'Sale';
    AddSaleList();
    ComputeSaleTotal;
  end;
  {$ENDIF}
  {$IFDEF ODOT_VMT}
  if (VMTFee <> 0) then
//20060310    AddVMTDEPSale( VMTFee, VMTReceiptData );
  begin
    DiscountAmount := (Round(StateTaxPerGallon * SaleVolume * 100.0)) / 100.0;
    AddVMTDisc(DiscountAmount, GradeNo);
  end;
  {$ENDIF}
  nPumpNo := 0;

  nNumber := 0;
  nAmount := 0;
  nExtAmount := 0;
  nQty := 1;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('SELECT * FROM POPUPMSG where MsgDepartment = :pMsgDepartment');
    parambyname('pMsgDepartment').AsString := inttostr(Dept.DeptNo);
    open;
    if recordcount > 0 then
    begin
      InitPopUpMsgRecord;
      PopUpMsg^.MsgType   := FieldByName('MsgType').AsInteger;
      PopUpMsg^.MsgTime   := 0;
      PopUpMsg^.MsgHeader := FieldByName('MsgHeader').AsString;
      for ndx := 1 to 10 do
      begin
        PopUpMsg^.MsgLine[ndx] := FieldByName('MsgLine'+ IntToStr(ndx)).AsString;
      end;
      PopUpMsgList.Capacity := PopUpMsgList.Count;
      PopUpMsgList.Add(PopUpMsg);
      fmPopUpMsg.ShowModal;
    end;
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
end;

{$IFDEF ODOT_VMT}
procedure TfmPOS.AddVMTDisc(const DiscountAmount : currency; const GradeNo : integer);
begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close();
    SQL.Clear;
    SQL.Add('SELECT * FROM Disc where RecType = :pRecType and');
    SQL.Add(' ((DiscNo = :pDiscNo1) or (DiscNo = :pDiscNo2)) order by DiscNo desc');
    ParamByName('pDiscNo1').AsInteger := STATE_TAX_FUEL_DISC_NO;
    ParamByName('pDiscNo2').AsInteger := STATE_TAX_FUEL_DISC_NO + GradeNo;
    ParamByName('pRecType').AsString := 'F';
    Open();
    if RecordCount > 0 then
    begin
      sLineType := 'DSV';
      sSaleType := 'Sale';    {Sale, Void, Rtrn, VdVd, VdRt}
      nDiscNo := FieldByName('DiscNo').AsInteger;
      nDiscType := 'F';
      nQty   := 1;
      nAmount := - DiscountAmount;
      fmPOS.AddGiftFuelDisc();
    end;
    Close();
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
end;  // procedure AddVMTDisc()

procedure tfmPOS.AddVMTDEPSale( VMTFee : currency; VMTReceiptData : WideString );
begin

  // get all the department data associated with department 995
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBDeptQuery do
  begin
    ParamByName('pDeptNo').AsInteger := 995;
    Open;
    if RecordCount = 0 then
    begin
      Close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      POSError('Department Not Found (ODOT VMT)');
      Exit;
    end;
    GetDept(POSDataMod.IBDeptQuery, @Dept);
    close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;

  if SaleState = ssNoSale then
    AssignTransNo;

  // the amount is our VMT fee
  nQty := 1;
  nAmount := VMTFee;
  DeptVMTReceiptData := VMTReceiptData;

  SaleState := ssSale;
  sLineType := 'DPT';
  sSaleType := 'Sale';

  AddSaleList;
  PoleMdse;
  ComputeSaleTotal;

end;
{$ENDIF}

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessPrePayRefund
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TWMProcessPrePayRefund
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessPrePayRefund(var Msg: TWMProcessPrePayRefund);
var
  PumpNo, SaleID : integer;
  RefundAmount   : currency;
  TempTransNo : Integer;
  XMDFound : Boolean;
  XMDAmount, OriginalAmount : Double;
  SD : pSalesData;
begin
  XMDFound := False;
  XMDAmount := 0;
  PumpNo       := Msg.ProcessPrePayRefundInfo.PumpNo;
  SaleID       := Msg.ProcessPrePayRefundInfo.SaleID;
  RefundAmount := Msg.ProcessPrePayRefundInfo.RefundAmount;
  Dispose(Msg.ProcessPrePayRefundInfo);
  //XMD
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select TransNo, PrePayAmount from FuelTran where SaleID = :pSaleID');
    parambyname('pSaleID').AsInteger := SaleID;
    Open;
    OriginalAmount := FieldByName('PrePayAmount').AsCurrency;
    TempTransNo := FieldByName('TransNo').AsInteger;
    Close;SQL.Clear;
    SQL.Add('Select * from Receipt where TransactionNo = :pTransNo');
    parambyname('pTransNo').AsInteger := TempTransNo;
    Open;
    while not eof do
    begin
      if FieldByName('LineType').AsString = 'XMD' then
      begin
        XMDFound := True;
        XMDAmount := XMDAmount + FieldByName('ExtPrice').AsCurrency;
      end;
      Next;
    end;
    Close;
  end;
  if XMDFound then
  begin
    if OriginalAmount = (RefundAmount * -1) then
      RefundAmount := RefundAmount - XMDAmount
    else if (OriginalAmount + RefundAmount)  < (XMDAmount * -1) then
      RefundAmount := RefundAmount - XMDAmount
    else if (RefundAmount * -1) <= (XMDAmount * -1) then
      RefundAmount := 0;
  end;
  //XMD

  if SaleState = ssNoSale then
    AssignTransNo;

  nPumpNo     := PumpNo;
  nQty        := 1;
  nAmount     := RefundAmount;
  SaleState   := ssSale;
  sLineType   := 'PRF';
  sSaleType   := 'Sale';
  nPumpSaleID := SaleID;

  SD := AddSaleList;
  PoleMdse(SD, SaleState);
  ComputeSaleTotal;
  ClearEntryField;
  nPumpNo := 0;

end;
{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessTdBarCode
  Author:    Sheshagiri
  Date:      18-Apr-2017
  Arguments: Array as Input parameter
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}

 procedure TfmPOS.ProcessTdBarCode( TdCode : String );
 Var
   i : integer;
 begin
 try
   if bSaleComplete then  // once Sale complete need to Initilize the Screen
    InitScreen();
   arPrdCode := ParseTdCode( TdCode);
   for i := 0 to  length( arPrdCode)-1 do
     begin
      nQty := arPrdCode[i,0];
      if arPrdCode[i,1] >0 Then
        ProcessKeyPLU(Floattostr(arPrdCode[i,1]), '');
     end;
 except
 on E : Exception do
       ShowMessage('Exception class name = '+E.ClassName);
 end;
 end;
{-----------------------------------------------------------------------------
  Name:      TfmPOS.Parse 2d Code
  Author:    Sheshagiri
  Date:      18-Apr-2017
  Arguments:
  Result:    None
  Purpose:   Sting of code is returned by the 2d Bar which is parsed into rows,
             Array with multiple rows are returned
-----------------------------------------------------------------------------}
Function TfmPOS.ParseTdCode(parseCode: String): TIntegerArray;
Var
 dCode,OdCode : String;
 iCnt,i,iLength : integer;
//arProdCode : TIntegerArray;
begin
  OdCode := parseCode;
  dCode :=  parseCode;
  iLength := 0;

  for i := 0 to length(OdCode) do
  begin
      iCnt := pos(',',OdCode);
      if iCnt = 0 Then Break;
      if iCnt > 0 then iLength := iLength + 1;
      OdCode := copy(OdCode,iCnt+1,length(OdCode));
  end;
   SetLength(Result,round(iLength/2)+1,2);
   i:=0;
  while length(dCode) <> 0 do
   begin

       iCnt := pos(',',dCode) ;
       if (iCnt <> 0) Then
       begin

          Result[i,0]  := StrToint(copy(dCode,1,iCnt-1));
          dCode := copy(dCode,iCnt+1,length(dCode));
          iCnt := pos(',',dCode);
          if (iCnt > 0) and (length(dCode) > 1) Then
          begin
             if iCnt = 0 Then iCnt := length(dCode)+1;
                Result[i,1] := StrToInt64(copy(dCode,1,iCnt-1));
             dCode := copy(dCode,iCnt+1,length(dCode))  ;
          end
          else
          begin
            Result[i,1] := StrToInt64(dCode);
            exit;
          end;
          i := i + 1;
        end
        else
         exit;
    end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyMOD
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyMOD(const sPreset : string);
begin

  nModifierValue  := StrToInt(sPreset);
  if bNeedModifier then
    begin
      //sKeyVal := '';
    end;

end;

{$IFDEF UPC_EXPAND}
//Code used for validating Check Digit on Kiosk sales
//20060922a... (function ValidateUPCCheckDigit uncommented)
//function ValidateUPCCheckDigit(enteredUPC : string; computedUPC : string) : string;
function TfmPOS.ValidateUPCCheckDigit(enteredUPC : string; computedUPC : string) : string;
//...20060922a
var
  oddFlag : boolean;
  oddSum : integer;
  evenSum : integer;
  checkSum : integer;
  checkDigit : string;
  i : integer;
begin
  oddFlag := true;
  oddSum := 0;
  evenSum := 0;
  checkDigit := '';
  for i := length(computedUPC) -1 downto 1 do
  begin
    if oddFlag then
      oddSum := oddSum + StrtoInt(computedUPC[i])
    else
      evenSum := evenSum + StrtoInt(computedUPC[i]);
    oddFlag := not oddFlag;
  end;
  checkSum := (oddSum * 3) + evenSum;
  if checkSum mod 10 = 0 then
    checkDigit := InttoStr(checkSum mod 10)
  else
    checkDigit := InttoStr(10 - checkSum mod 10);

//if the computed Check Digit equals the last digit of the UPC number,
//Send the first 11 characters of the computed UPC,
//otherwise send the original UPC
  //20060922a...
//  if checkDigit = computedUPC[12] then
//    ValidateUPCCheckDigit := MidStr(computedUPC,1,11)
  if checkDigit = computedUPC[Length(computedUPC)] then
    ValidateUPCCheckDigit := MidStr(computedUPC,1,Length(computedUPC) - 1)
  //...20060922a
  else
    ValidateUPCCheckDigit := enteredUPC;
end;

function ExpandUPCEtoUPCA(UPC : string) : string;
var
  localUPC : string;
begin
  localUPC := MidStr(UPC,2,6);
  case localUPC[6] of
    '0','1','2':
    begin
      localUPC := MidStr(localUPC,1,2) + MidStr(localUPC,6,1) + '0000' + MidStr(localUPC,3,3);
    end;
    '3':
    begin
      localUPC := MidStr(localUPC,1,3) + '00000' + MidStr(localUPC,4,2);
    end;
    '4':
    begin
      localUPC := MidStr(localUPC,1,4) + '00000' + MidStr(localUPC,5,1);
    end;
    '5','6','7','8','9':
    begin
      localUPC := MidStr(localUPC,1,5) + '0000' + MidStr(localUPC,6,1);
    end;
  end;
  ExpandUPCEtoUPCA := MidStr(UPC,1,1) + localUPC {$IFDEF INCLUDE_UPC_CHECK_DIGIT} + MidStr(UPC,8,8) {$ENDIF};
end;
{$ENDIF}

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPLU
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPLU(const sKeyVal : string; const sPreset : string);
var
  nLookUpPLUNo : currency;
//cwe...
  bAccessApproved : boolean;
  bCarwashPLU : boolean;
  sAccessCode : string;
  PLUNumber : int64;
//...cwe
//cwf...
  sCWExpDate : string;
//...cwf
  {$IFDEF UPC_EXPAND}
  sExpEntry : string;
  {$ENDIF}
  tmpQty : currency;
  SD : pSalesData;
  mr : integer;
begin
  if (sPreset <> 'CardActivation') and (StrToCurrDef(sEntry,0) > 100000) then
    InitActivationDataForSaleItem(@ActivationProductData)
  else
  begin
    ActivationProductData.ActivationAmount := StrToCurrDef(sEntry,0)/100;
  end;

  if sKeyVal <> '' then
    sEntry := sKeyVal;

  if sEntry = '' then
  begin
    if not POSDataMod.PLUMemTable.Active then POSDataMod.PLUMemTable.Open;
    if (POSDataMod.PLUMemTable.RecordCount = 0) then
      LoadPLUMemTable;

    frmPLULookup.ItemSelected := False;
    frmPLULookUp.Show;
    while frmPLULookup.Visible = True do
    begin
      Application.ProcessMessages;
      sleep(20);
    end;
    if frmPLULookUp.ItemSelected = True then
    begin
      sEntry := FloatToStr(frmPLULookUp.SelectedPLU);
      nModifierValue := frmPLULookUp.SelectedPLUModifier;
    end
    else
      exit;
  end;

  //20060922a...
  if (Copy(sEntry,1,1) = '8') and (length(sEntry) = 13) then
  begin
    //?sKeyVal  := '';
    KeyBuff := '';
    BuffPtr := 0;
    //?sPreset  := '';

    if (SaleState  = ssNoSale) and (not fmValidAge.Visible) and (not fmPriceCheck.Visible)
      and (not fmPriceOverride.Visible) and (not fmEnterAge.Visible) then
      InitScreen;
    ProcessKeyKSL;
    exit;
  end;
  //...20060922a
  if (copy(sEntry,2,1) = ',') Then
  begin
    ProcessTdBarCode(sEntry);
    exit;
  end;
  {$IFDEF GTIN_SUPPORT}   //20060913 Support for 15 digit GTIN PLUs
  if length(sEntry) > 15 then
  {$ELSE}
  if length(sEntry) > 12 then
  {$ENDIF}
  begin
    POSError('Invalid Numeric Entry');
    exit;
  end;

  try
    nNumber := StrToFloat(sEntry);
  except
    nNumber := 0;
  end;

  if nNumber = 0 then
    POSError('Please Enter A PLU Number');

  {$IFDEF INCLUDE_UPC_CHECK_DIGIT}
  // Verify check digit (if long enough for a UPC entry - otherwise, assume a PLU entry)
  if (length(sEntry) >= 7) then  // Assume a UPC code
  begin
    if length(sEntry) = 7 then
      sExpEntry := ExpandUPCEtoUPCA('0' + sEntry)
    else if length(sEntry) = 8 then
      sExpEntry := ExpandUPCEtoUPCA(sEntry)
    else
      sExpEntry := sEntry;
    if (sExpEntry = fmPOS.ValidateUPCCheckDigit(sExpEntry, sExpEntry)) then
    begin
      POSError('Invalid UPC check digit');
      exit;
    end;
  end;
  {$ENDIF}

  //cwe...

  // If a carwash PLU, then get access code from carwash server (if not already requested).
  try
    PLUNumber := Trunc(nNumber + 0.5);
  except
    PLUNumber := 0;
  end;
  if ((PLUNumber > 0) and (sCarwashAccessCode = '')) then
    begin
      // See if PLU matches a carwash department (determined by group number).
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
      try
        Close();SQL.Clear();
        SQL.Add('SELECT P.Name Name, D.DeptNo DeptNo, G.GrpNo GrpNo');
        SQL.Add(' from PLU P, Dept D, Grp G');
        SQL.Add(' WHERE P.PLUNo = ' + sEntry);
        SQL.Add(' and (P.DelFlag = 0 or P.DelFlag is null)');  //20070213a
        SQL.Add(' and P.DeptNo=D.DeptNo and D.GrpNo=G.GrpNo and G.Fuel=' + CARWASH_GROUP_TYPE);
        Open();
        bCarwashPLU := (not EOF);
        Close();
       except
         //on E: Exception do Showmessage(E.Message);
       end;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      if (bCarwashPLU) then
      begin
        // Request a carwash access code.  If one cannot be obtained, then exit PLU processing.
        sCarwashAccessCode := '';
        //cwf...
        //sAccessCode := RequestCarwashAccessCode(PLUNumber);
        sCarwashExpDate := '';
        sAccessCode := RequestCarwashAccessCode(PLUNumber, sCWExpDate);
        //...cwf
        bAccessApproved := (sAccessCode <> '');
        fmCWAccessForm.SetCWClientData(curSale.nTransNo, GC_NONE);
        // If a carwash access code was granted, then continue processing item as a PLU.
        if (bAccessApproved) then
        begin
          sCarwashAccessCode := sAccessCode;
          //cwf...
          sCarwashExpDate := sCWExpDate;
          //...cwf
        end
        else
        begin
          exit;
        end;
      end;  // if (bCarwashPLU)
    end;  // if (PLUNumber > 0)

  //...cwe
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBPLUQuery do
  begin
    {$IFDEF UPC_EXPAND}
    if length(sEntry) = {$IFDEF INCLUDE_UPC_CHECK_DIGIT} 7 {$ELSE} 6 {$ENDIF} then
      sExpEntry := ExpandUPCEtoUPCA('0' + sEntry)
    else if length(sEntry) = {$IFDEF INCLUDE_UPC_CHECK_DIGIT} 8 {$ELSE} 7 {$ENDIF} then
      sExpEntry := ExpandUPCEtoUPCA(sEntry)
    else
      sExpEntry := '0';
    Close;
    SQL.Clear;
    //20070213a...
//    SQL.Add('Select * from PLU where PLUNo = :pNumber or UPC = :pUPC');
    SQL.Add('Select * from PLU where (DelFlag = 0 or DelFlag is null) and (PLUNo = :pNumber or UPC = :pUPC)');
    //...20070213a
    ParamByName('pNumber').AsCurrency := StrtoFloat(sExpEntry);
    ParamByName('pUPC').AsCurrency    := StrtoFloat(sExpEntry);
    Open;
    if EOF then
    begin
      sExpEntry := '0';
      Close;
      SQL.Clear;
      //20070213a...
//      SQL.Add('Select * from PLU where PLUNo = :pNumber or UPC = :pUPC');
      SQL.Add('Select * from PLU where (DelFlag = 0 or DelFlag is null) and (PLUNo = :pNumber or UPC = :pUPC)');
      //...20070213a
      ParamByName('pNumber').AsCurrency := nNumber;
      ParamByName('pUPC').AsCurrency    := nNumber;
      Open;
    end
    else
    begin
      sEntry := sExpEntry;
      nNumber := StrtoFloat(sExpEntry);
    end;
    {$ELSE}
    Close;
    SQL.Clear;
    //20070213a...
//    SQL.Add('Select * from PLU where PLUNo = :pNumber or UPC = :pUPC');
    SQL.Add('Select * from PLU where (DelFlag = 0 or DelFlag is null) and (PLUNo = :pNumber or UPC = :pUPC)');
    //...20070213a
    ParamByName('pNumber').AsCurrency := nNumber;
    ParamByName('pUPC').AsCurrency    := nNumber;
    Open;
    {$ENDIF}
    if not EOF then
    begin
      GetPLU(POSDataMod.IBPLUQuery, @PLU);
      nLinkedPLUNo := PLU.LINKEDPLU;
      close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
    end
    else
    begin
      close;
      if Boolean(Setup.CaptureNFPLU) then
      begin
        with POSDataMod.IBNFPLUQuery do
        begin
          Close;SQL.Clear;
          SQL.Add('Select * from NFPLU where PLUNo = :pPLUNo');
          ParamByName('pPLUNo').AsCurrency := nNumber;
          Open;
          if NOT EOF then
          begin
            sEntry  := IntToStr(Trunc(POSDataMod.IBNFPLUQuery.FieldByName('Price').AsCurrency * 100 ));
            ProcessKeyDPT(IntToStr(POSDataMod.IBNFPLUQuery.FieldByName('DeptNo').AsInteger), '');
            Close;
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Commit;
            exit;
          end;
          close;
        end;
      end;
      nCaptureNFPLUNumber := nNumber;
      fmPOSErrorMsg.CapturePLU :=  Boolean(Setup.CaptureNFPLU) ;
      POSError('PLU Number "' + CurrToStr(nNumber) + '" Not Found');            //20060922a (Added PLU number to error message)
      fmPOSErrorMsg.CapturePLU := False;
      if fmPOSErrorMsg.ModalResult = mrYes then
      begin
        nCurMenu := Setup.NFPLUMenu;
        DisplayMenu(nCurMenu);
        bCaptureNFPLU := True;
      end;
      //Build 17
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBNFPLUQuery do
      begin
        //20060713e...
        Close;SQL.Clear;
        SQL.Add('Select PLUNo FROM NFPluExp WHERE PLUNo = :pPLUNo ');  //GMM:  Added to prevent error upon subsequent entries of Not Found PLU
        ParamByName('pPLUNo').AsCurrency := nCaptureNFPLUNumber;
        Open;
        if EOF then
        begin
        //...20060713e
          Close;SQL.Clear;
          SQL.Add('Insert into NFPluExp ( PLUNo, TransDate) Values (:pPLUNo, :pTransDate)');
          ParamByName('pPLUNo').AsCurrency := nCaptureNFPLUNumber;
          ParamByName('pTransDate').AsDate := now();
          try
            ExecSQL;
          except
          end;
        end;  //20060713e
        Close;
      end;
      //Build 17
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      exit;
    end;
  end;
  ActivationProductData.ActivationPhoneNo := ''; // Shesh to initialize the  Phoneno
  // Check to see if item requires product activation.
  if (PLU.NeedsActivation) then
  begin
    if (nQty <> 1) and PLU.NeedsSwipe then
    begin
      ClearActivationProductData(@ActivationProductData);
      POSError('Swiped cards may only be QTY 1');
      exit;
    end;
    // Some activation products require additional information from a card swipe.
    if (PLU.NeedsSwipe and (ActivationProductData.ActivationCardNo = '')) then
    begin
      ActivationProductData.bNextSwipeForProduct := True;
      ActivationProductData.ActivationUPC := CurrToStr(PLU.Upc);
      ActivationProductData.ActivationAmount := PLU.Price;
      IssueCardActivationPrompt('Swipe phone card');
      exit;
    end
    else if (PLU.NeedsPhone and (not assigned(PPTrans) or not PPTrans.PinPadOnLine)) then
    begin
      POSError('Cannot request phone number from PINPad');
      exit;
    end
    else if (PLU.NeedsPhone and (ActivationProductData.ActivationPhoneNo = '')) then
    begin
      PPTrans.GetPhoneNo;
      mr := fmPPEntryPrompt.ShowPrompt('Waiting for Phone Number at PINPad');
      if (mr = mrOK) then
      begin
        ActivationProductData.bNextSwipeForProduct := True;
        ActivationProductData.ActivationUPC := CurrToStr(PLU.Upc);
        ActivationProductData.ActivationAmount := PLU.Price;
        ActivationProductData.ActivationPhoneNo := fmPPEntryPrompt.response;
        ActivationProductData.ActivationEntryType := ENTRY_TYPE_BARCODE;
      end
      else if (mr = mrAll) then
      begin
        PPTrans.StopOnDemand;
        exit;  // local cancel
      end
      else
      begin
        POSError('Customer Canceled/Declined');
        exit;
      end;
    end
    else
    begin
      // Validate face value (if barcode has already been scanned).
      if ((ActivationProductData.ActivationAmount <> 0.0) and (ActivationProductData.ActivationAmount <> PLU.Price)) then
      begin
        if (PLU.PRICE <> 0) then
        begin
          POSError(FormatFloat('$#,###.00 ;$#,###.00-', ActivationProductData.ActivationAmount) + ' amount on card does not match');
          exit;
        end
        else
          PLU.Price := ActivationProductData.ActivationAmount;
      end;
      // Activation UPC OK:
      if (ActivationProductData.ActivationEntryType <> ENTRY_TYPE_MSR) then
        ActivationProductData.ActivationEntryType := ENTRY_TYPE_BARCODE;
    end;
  end;

  if (PLU.ModifierGroup > 0) and (nModifierValue = 0) then
  begin
    if bUseDefaultModifier then
    begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select * from Modifier Where ModifierGroup = :pModifierGroup Order By ModifierNo');
        ParamByName('pModifierGroup').AsCurrency := PLU.ModifierGroup;
        Open;
        while not EOF do
        begin
          if FieldByName('ModifierDefault').AsInteger = 1 then
          begin
            nModifierValue := FieldByName('ModifierNo').AsInteger;
            break;
          end;
          Next;       //GMM:  Added to prevent infinite loop                     //20060707
        end;
        if nModifierValue = 0 then
        begin
          First;
          nModifierValue := FieldByName('ModifierNo').AsInteger;
        end;
        close;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
    {$IFDEF PLU_MOD_DEPT}
    end;
    // Allow selection with with default.
    {$ELSE}
    end
    else  // Only allow selection when default not used.
    {$ENDIF}
    begin
      DisplayModifierMenu(PLU.ModifierGroup);
      bNeedModifier := True;
      exit;
    end;
  end;
  {$IFDEF PLU_MOD_DEPT}  //20060720
  // Need to update department from modifier if specified.
  If ((PLUModifierGroup > 0) and (nModifierValue <> 0)) then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBPLUModQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('Select * from PLUMod where PLUNo = :pPLUNo and PLUModifier = :pPLUModifier');
      ParamByName('pPLUNo').AsCurrency       := nNumber;
      ParamByName('pPLUModifier').AsCurrency := nModifierValue;
      Open;
      if RecordCount > 0 then
      begin
        PLUDeptNo := fieldbyname('DeptNo').AsInteger;
        PLUSplitQty := fieldbyname('SplitQty').AsInteger;
        PLUSplitPrice := fieldbyname('SplitPrice').AsCurrency;
        close;
      end;
    end;
  end;
  {$ENDIF}
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBDeptQuery do
  begin
    ParamByName('pDeptNo').AsInteger := PLU.DeptNo;
    Open;
    if EOF then
    begin
      close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      POSError('Invalid Category Link');
      exit;
    end;
    GetDept(POSDataMod.IBDeptQuery, @Dept);
    close;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
    if Dept.RestrictionCode > 0 then
      if not RestrictionCodeOK(Dept.RestrictionCode) then
        Exit;
    if Dept.MaxCount > 0 then
      if not DepartmentMaxCountOK(Dept.DeptNo, Dept.MaxCount) then
        exit;
  end;

  tmpQty := 0;
  if PLU.NeedsActivation and (nQty > 1) then
  begin
    tmpQty := nQty - 1.0;
    nQty := 1;
  end;

  if PLU.weighed and (nQty = 0) then
  begin
    if setup.SCALEITEMS and assigned(scale) then
    begin
      scale.sendweights( ScaleWeightFrm.SetValue );
      if isPositiveResult(ScaleWeightFrm.ShowModal()) then
      begin
        nQty := ScaleWeightFrm.Display.Value;
        scale.stopweights;
        if (nQty = 0) or (nQty = 9999) then
        begin
          nQty := 0;
          ClearEntryField;
          exit;
        end;
      end
      else
      begin
        scale.stopweights;
        ClearEntryField;
        exit;
      end;
    end
    else
    begin
      POSError('Support for weighed items not enabled');
      exit;
    end;
  end
  else if not PLU.weighed and (nQty = 0) then
    nQty := 1;

  SD := PostItemSale;

  nQty := tmpQty;

// could put a loop here to allow link of multiple items if needed
  if nLinkedPLUNo > 0 then
  begin
    nLookUpPLUNo := nLinkedPLUNo;  // point back to item that started link
    nLinkedPLUNo := nNumber;  // point back to item that started link
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBPLUQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('Select * from PLU where PLUNo = :pPLUNo');
      SQL.Add(' and (DelFlag = 0 or DelFlag is null)');  //20070213a
      ParamByName('pPLUNo').AsCurrency := nLookUpPLUNo;
      Open;
      GetPLU(POSDataMod.IBPLUQuery, @PLU);
      nLinkedPLUNo := PLU.LINKEDPLU;
      if NOT EOF then
      begin
        close;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        SD := PostItemSale;
      end
      else
        close;//build 47 to fix posting
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end;

  if tmpQty = 0 then
  ClearEntryField;

  CheckItemForActivation(SD, @ActivationProductData);
  
  if tmpQty <> 0 then
    ProcessKeyPLU(sKeyVal, sPreset);
end;

procedure CreateVCI(const pVCI : pValidCardInfo ; const Cardtype, CardNo, ExpDate, CardName, VehicleNo : string);
begin
  ZeroMemory(pVCI, sizeof(TValidCardInfo));
  pVCI.cardsource        := csThinAir;
  pVCI.CardType          := Cardtype;
  pVCI.CardNo            := CardNo;
  pVCI.ExpDate           := ExpDate;
  pVCI.CardName          := CardName;
  pVCI.VehicleNo         := VehicleNo;
  pVCI.bValid            := True;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyMED
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyMED(const sKeyType : string ; const sKeyVal : string ; const sPreset : string ;
                               const bPostTender : boolean);
var
  ndx : short;
  //Gift
  nAmountSave : currency;
  bCompleteAuth : boolean;         // (partialauth)
  sd : pSalesData;
  //Gift
  //cwa...
  //53o...
  AuthAmount : currency;
  //...53o
  QualifiedMoneyOrderMedia : currency;
  TotalMoneyOrderAmount : currency;
  {$IFDEF CASH_FUEL_DISC}
  CashMediaApplied : currency;
  j2 : integer;
  {$ENDIF}
  Preset : string;
  TempAuthData : pValidCardInfo;
  ShowPartialTender : boolean;
begin
  UpdateZLog(Format('ProcessKeyMED - sEntry = "%s", sKeyType = "%s", sKeyVal = "%s"',[sEntry, sKeyType, sKeyVal]));

  // Do not allow tender while product activations are outstanding (or until they timeout).
  if (ProductActivationPending(@(CurSaleList))) then
  begin
    POSError('Tender not allowed during activations');
    exit;
  end;
  InitializeCRD(@rCRD);

  //53o...
  AuthAmount := 0.0;
  //...53o
  Preset := sPreset;
  ClearMedia(@Media);
  bCompleteAuth := False;  // Default assumption for now.
  //if (Media.MEDIANO <> NULL_MEDIA_NUMBER) then
  if (sKeyVal = IntToStr(NULL_MEDIA_NUMBER)) then
  begin
    // This call to ProcessKeyMed is finalizing the sale after all media has been tendered;
    // therefore, it is not necessary to extract media information from the DB.
    Media.MEDIANO := NULL_MEDIA_NUMBER;
  end
  else
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBMediaQuery do
    begin
      try
        ParamByName('pMediaNo').AsInteger := StrToInt(sKeyVal);
      except
        ParamByName('pMediaNo').AsInteger := 0;
      end;
      Open;
      if not EOF then
      begin
        GetMedia(POSDataMod.IBMediaQuery, @Media);
        close;
      end
      else
      if EOF then
      begin
        POSError('Media Not Found');
        Close;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        Exit;
      end;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
    if sKeyType = 'NMD' then
    begin
      if Length(Trim(POSButtons[nNextDollarKey].Caption)) = 0 then
        Exit;
      Preset := Copy( Trim(POSButtons[nNextDollarKey].Caption), 2, Length(Trim(POSButtons[nNextDollarKey].Caption)) - 1) + '00';
      if (SaleState in [ssSale]) and
         ((Pos('Coupon',POSListBox.Items.Strings[POSListBox.Items.Count-1]) > 0) or
         (Pos('Cash',POSListBox.Items.Strings[POSListBox.Items.Count-1]) > 0)) then
      begin
        nAmount := curSale.nAmountDue  * 100;
        SaleState := ssTender;
      end;
    end;
    if Preset <> '' then
    begin
      sEntry := Preset;
      nAmount := curSale.nAmountDue  * 100;
    end;

    if sKeyType = 'XCT' then
    begin
      if (SaleState in [ssTender, ssBankFuncTender]) or
         ((SaleState in [ssSale]) and
         ((Pos('Coupon',POSListBox.Items.Strings[POSListBox.Items.Count-1]) > 0) or
         (Pos('Cash',POSListBox.Items.Strings[POSListBox.Items.Count-1]) > 0))) then
      begin
        nAmount := curSale.nAmountDue  * 100;
        SaleState := ssTender;
      end
      else
      begin
        nAmount := curSale.nTotal * 100;
        //Build 31
        PinCreditSelect := 0;
      end;
      sEntry := FloatToStr(nAmount);
    end;

    if sEntry = '' then
    begin
      if Media.AmountCompulse and (curSale.nTotal > 0) then
      begin
//        {$IFDEF CASH_FUEL_DISC}
//        if (MedRecType = CASH_MEDIA_TYPE) then
//        begin
//          CashFuelDiscPerGallon := 0.0;  // initial assumption
//          try
//            if not POSDataMod.IBTransaction.InTransaction then
//              POSDataMod.IBTransaction.StartTransaction;
//            with POSDataMod.IBTempQuery do
//            begin
//              Close();
//              SQL.Clear();
//              SQL.Add('Select Amount from Disc where RecType = ''F'' and DiscNo = :pDiscNo');
//              ParamByName('pDiscNo').AsInteger := CASH_FUEL_DISC_NO;
//              Open;
//              if (RecordCount > 0) then
//                CashFuelDiscPerGallon := FieldByName('Amount').AsCurrency;
//              Close();
//            end;  // with
//            if POSDataMod.IBTransaction.InTransaction then
//              POSDataMod.IBTransaction.Commit;
//          except
//            CashFuelDiscPerGallon := 0.0;
//            UpdateExceptLog('ProcessKeyMED - Cannot determine cash fuel discount amount');
//          end;
//          ApplyDiscount(CASH_FUEL_DISC_NO);
//        end;  // if (MedRecType = CASH_MEDIA_TYPE)
//        {$ENDIF}
        POSError('Please Enter An Amount');
        Exit;
      end
      else
      begin
        nAmount := curSale.nAmountDue  * 100
      end;
    end
    else
      nAmount := StrToFloat(sEntry);
      if (SaleState in [ssSale]) and
         ((Pos('Coupon',POSListBox.Items.Strings[POSListBox.Items.Count-1]) > 0) or
         (Pos('Cash',POSListBox.Items.Strings[POSListBox.Items.Count-1]) > 0)) then
         SaleState := ssTender;

      { add an overtender check here }

    nAmount := nAmount / 100;
    nAmount := POSRound(nAmount,2);

    if (Media.HALO > 0) and
       (nAmount > Media.HALO) then
    begin
      POSError('Over High Amount Limit');
      Exit;
    end;
    if (SaleState in [ssBankFunc, ssBankFuncTender]) then
      if Media.RecType > 2 then
      begin
        POSError('Media Not Allowed in Bank Function');
        Exit;
      end;


    if (curSale.nAmountDue < 0) and (nAmount > 0) then
    begin
      nAmount := nAmount * -1;
    end;
    if (SaleState in [ssBankFunc, ssBankFuncTender]) or
       (Boolean(Media.AllowOverTend) = False) then
      if abs(nAmount) > abs(curSale.nAmountDue) then
      begin
        POSError('Over Tendering is Not Allowed');
        Exit;
      end;

    //53o...
//    if MedRecType = 6 then
    if (Media.RecType = FOOD_STAMP_MEDIA_TYPE) then
    //...53o
    begin
      if (bUseFoodStamps = False) or (curSale.nFSSubtotal <= 0) then
      begin
        POSError('Food Stamp Tendering is Not Allowed');
        Exit;
      end;

      // Must tender food stamps first
      if ( SaleState in [ssTender, ssBankFuncTender]) then
      begin
        POSError('Food Stamp Tendering is Not Allowed');
        Exit;
      end;
    end;

    // Check for final tender:
    if ((nAmount > 0.0) and (nAmount >= curSale.nAmountDue)) then
    begin
      {$IFDEF FUEL_PRICE_ADJUST}
      // Enforce any rules for discounted fuel prices (based on media tendered)
      if ((Media.MEDIANO <> CREDIT_MEDIA_NUMBER) and  // Card tenders must be handled in NBSCC (after payment type selected).
          (nAmount > 0.0) and
          (nAmount >= nCurAmountDue)) then
      begin
        if (not AdjustFuelPriceForTender(nAmount, Media.MEDIANO, '')) then
          exit;
      end;
      {$ENDIF}
    end;  // if final tender
    if ((Media.RecType = CREDIT_MEDIA_TYPE) or
        ((Media.RecType = DEFAULT_GIFT_CARD_MEDIA_TYPE) and bPostTender) or
       ((Media.RecType = CHECK_MEDIA_TYPE) and Setup.AuthorizeChecks)) then
    begin
      if (CreditHostReal(nCreditAuthType)) then
      begin
        qClient^.CreditTransNo := curSale.nTransNo;  // Used to match responses from credit server.
        ReComputeSaleTotal(True);
        //Gift
        fmNBSCCForm.Authorized := 0;
        fmNBSCCForm.ChargeAmount := nAmount;
        AuthAmount := fmNBSCCForm.ChargeAmount;
        //...53o
        fmNBSCCForm.Preauth := IsActivationQueued();
        fmNBSCCForm.CurrentTransNo := curSale.nTransNo;
        fmNBSCCForm.AmountDue    := curSale.nTotal;
        fmNBSCCForm.TaxAmount :=  curSale.nTlTax;
        if not bPostTender then fmNBSCCForm.InitialScreen();
        fmNBSCCForm.SalesList := CurSaleList;
        if (fmNBSCCForm.Visible) then 
        begin
           fmNBSCCForm.Visible := False;
        end;
        // here is where we need to make the following calls to the device
        // 14.x, 13.x and 23.x (card read) commands need to be issued
        //SendCancelOnDemand(PPTrans);
        SendSetTransactionType(PPTrans);
        SendSetAmount(PPTrans);
        PPTrans.CheckSignatureEntry := '';
        PPTrans.SwipeCheckCount := 0;
        PPTrans.IsFallbackTransaction := False;
        PPTrans.InvalidPIN_EnteredCount := 0;
        //Reset OnlineT99Switch
        OnlineT99Switch := False;
        OnlinePINVerified := False;
        EMV_Received_33_03 := False;
        //SendCardRead(PPTrans);
        fmNBSCCForm.ShowModal;     // main authorization
        //fmNBSCCForm.ResetLabels;
        // Default to showing PT window if we are authorized for a different amount than we asked for
        // We don't know before calling the ShowModal above what kind of card has been selected, so we always "ask"
        // for the transaction total.  This is incorrect in the case of restricted payment types like EBT and Fleet.
        ShowPartialTender := (fmNBSCCForm.Authorized <> 0)  and (fmNBSCCForm.ChargeAmount <> 0) and (nAmount <> fmNBSCCForm.ChargeAmount);
        //UpdateZLog('ProcessKeyMED - bCompleteAuth is True, nAmount = %.2f', [nAmount]);
        UpdateZLog('fmNBSCCForm.Authorized = ' + IntToStr(fmNBSCCForm.Authorized));
        UpdateZLog('fmNBSCCForm.ChargeAmount = %.2f', [fmNBSCCForm.ChargeAmount]);
        UpdateZLog('nAmount = %.2f', [nAmount]);
        if ShowPartialTender then
        begin
          if (rCRD.sCCCardType = CT_GIFT) then
            ShowPartialTender := False
          else if (rCRD.sCCCardType = CT_EBT_FS) then
            ShowPartialTender := fmNBSCCForm.ChargeAmount < curSale.nFSSubtotal
          else if (rCRD.sCCCardType = CT_DEBIT) then
            ShowPartialTender := False;
        end;
        if ShowPartialTender then
        begin
          frmPTVerify.PreviousBalance := nAmount;
          frmPTVerify.Tendered := fmNBSCCForm.ChargeAmount;
          if (frmPTVerify.ShowModal() = mrCancel) then
          begin
            nAmount := 0;
            //Media.MEDIANO := NULL_MEDIA_NUMBER;  //ensure this doesn't get added to the sales list
            fmNBSCCForm.Authorized := 0;
            fmNBSCCForm.ChargeAmount := 0;
            fmNBSCCForm.ClearCardInfo;
            bCompleteAuth := False;
            AssignTransNo();
            // VOID auth
            new(TempAuthData);
            CreateVCI(TempAuthData, rCRD.sCCCardType, rCRD.sCCCardNo, rCRD.sCCExpDate, rCRD.sCCCardName, rCRD.sCCVehicleNo);
            TempAuthData^.AuthID := rCRD.nCCAuthID;
            TempAuthData^.FinalAmount := 0;
            UpdateZLog('Before : mNBSCCForm.VCIReceived(TempAuthData)-tarang');
            //ShowMessage('Before : mNBSCCForm.VCIReceived(TempAuthData)'); // madhu  remove
            fmNBSCCForm.VCIReceived(TempAuthData);   //MADHU G V CHECK FOR AUTH
            dispose(TempAuthData);
            fmNBSCCForm.CurrentTransNo := curSale.nTransNo;
            fmNBSCCForm.ChargeAmount := 0;
            fmNBSCCForm.InitialScreen();
            UpdateZLog('Before1 : mNBSCCForm.ShowModal-tarang');
         //   ShowMessage('Before1 : mNBSCCForm.ShowModal');  // madhu  remove

         
            
            fmNBSCCForm.ShowModal();   // partial tender reject  // madhu g v start

           { fmNBSCCForm.ChargeAmount  := nAmount;
            rCRD.sCCCardType := CT_VISA;
            rCRD.sCCExpDate := '06/20';
            rCRD.sCCCardNo := '4639170031070990';
            rCRD.sCCCardName := 'VISA';
            fmNBSCCForm.Authorized := 1;
            nAmount := fmNBSCCForm.ChargeAmount;  }             // madhu g v end

          end
          else
          begin
            nAmount := fmNBSCCForm.ChargeAmount;
            bCompleteAuth := True;
          end;
        end
        else
        begin
          nAmount := fmNBSCCForm.ChargeAmount;
          bCompleteAuth := True;
        end;
      end; //  if CreditHostReal()
    //53g...
//    end;  // if media type is 3
    end;  // if media type is credit or check
    //...53g
  end; //end if not recall suspended credit
  if (bCompleteAuth) then
  begin
    //fmNBSCCForm.Authorized := 1;
    nAmount := fmNBSCCForm.ChargeAmount;
    UpdateZLog('ProcessKeyMED - bCompleteAuth is True, nAmount = %.2f', [nAmount]);
    if bPOSForceClose then
      exit;
    PinCreditSelect := 0;
    //Build 26
   // ShowMessage('ProcessKeyMED - fmNBSCCForm.Authorized'); // madhu remove
    UpdateZLog('ProcessKeyMED - fmNBSCCForm.Authorized = %d', [fmNBSCCForm.Authorized]);
    if fmNBSCCForm.Authorized = 0 then //declined
    Begin
    //20020205...
//      bGiftFailed := true;
      qClient^.bCreditAuthFailed := True;
    //...20020205
      ClearEntryField;
      if not PartialTender then
      begin
        SaleState := ssNoSale;
        SaleState := ssSale;
      end
      else
        SaleState := ssTender;
      //53k...
//      //53h...
//      AssignTransNo();
//      //...53h
      //...53k
      //53o...
      PrintEBTDecline(AuthAmount);
      //...53o
      Exit;
    End
    else
    begin
      bCCUsed := True;
      //53o... (todo) Does EBT need a media type?
      if StrToIntDef(rCRD.sCCCardType, 0) in [nCT_DEBIT, nCT_EBT_FS, nCT_EBT_CB, nCT_GIFT] then
      with POSDataMod.IBMediaQuery do
      begin
        if not Transaction.InTransaction then
          Transaction.StartTransaction;
        SQL.Clear;
        SQL.Add('Select * from Media where MediaNo = :pMediaNo');
        case StrToIntDef(rCRD.sCCCardType, 0) of
          nCT_DEBIT  : begin
                         bDebitUsed := True;
                         ParamByName('pMediaNo').AsInteger := StrToIntDef(sDebitMediaNo, 0);
                       end;
          nCT_EBT_FS :   ParamByName('pMediaNo').AsInteger := StrToIntDef(sEBTFSMediaNo, 0);
          nCT_EBT_CB : begin
                         bDebitUsed := True;
                         ParamByName('pMediaNo').AsInteger := StrToIntDef(sEBTCBMediaNo, 0);
                       end;
          nCT_GIFT   :   ParamByName('pMediaNo').AsInteger := StrToIntDef(sGiftCardMediaNo, 0);
        end;
        Open;
        GetMedia(POSDataMod.IBMediaQuery, @Media);
        Close;
        Transaction.Commit;
      end;
    end;
  end;//bCompleteAuth
  if (not (SaleState in [ssTender, ssBankFuncTender])) then
  begin
    if SaleState = ssBankFunc then
      SaleState := ssBankFuncTender
    else
      SaleState := ssTender;
    //Gift
    //nCurAmountDue := POSRound(nCurTotal,2);
    //Gift
    UpdateZLog('BeginToFinalize-tarang');
   // ShowMessage('BeginToFinalize'); // madhu remove
    BeginToFinalize;
    PoleTL(curSale.nTotal);
    UpdateZLog('PoleTL(curSale.nTotal)-tarang');
 //   ShowMessage(' PoleTL(curSale.nTotal)'); // madhu remove
  end;

  //53o...
//  if MedRecType = 6 then
  if (Media.RecType = FOOD_STAMP_MEDIA_TYPE) then
  //...53o
  begin
    curSale.nFSChange := 0;
    if nAmount > curSale.nFSSubtotal then
    begin
      curSale.nFSChange := nAmount - curSale.nFSSubtotal;
      nAmount := curSale.nFSSubtotal;
      UpdateZLog('ProcessKeyMED - FS adjusted nAmount to %.2f because it''s higher than nCurFSSubtotal: %.2f', [nAmount, curSale.nFSSubtotal]);
    end;
  end;  // if (MedRecType = FOOD_STAMP_MEDIA_TYPE)
  {$IFDEF CASH_FUEL_DISC}
//  if ((MedRecType = CASH_MEDIA_TYPE) and (MedMediaNo = CASH_MEDIA_NUMBER)) then
  // If final tender, then check for cash fuel discounts.
  if ((nAmount >= curSale.nAmountDue) and (curSale.nAmountDue > 0.0)) then
  begin
    // Determine cash amount that applies to this transaction (including this final tender)
    CashMediaApplied := 0;
    for j2 := 0 to CurSalelist.Count - 1 do
    begin
      sd := CurSaleList.Items[j2];
      if ((sd^.LineType = 'MED') and (sd^.Number = CASH_MEDIA_NUMBER)) then
        CashMediaApplied := CashMediaApplied + sd^.ExtPrice;
    end;
    if ((Media.RecType = CASH_MEDIA_TYPE) and (Media.MediaNo = CASH_MEDIA_NUMBER)) then
      CashMediaApplied := CashMediaApplied + nAmount;
//    CashFuelDiscPerGallon := 0.0;  // initial assumption
//    try
//      if not POSDataMod.IBTransaction.InTransaction then
//        POSDataMod.IBTransaction.StartTransaction;
//      with POSDataMod.IBTempQuery do
//      begin
//        Close();
//        SQL.Clear();
//        SQL.Add('Select Amount from Disc where RecType = ''F'' and DiscNo = :pDiscNo');
//        ParamByName('pDiscNo').AsInteger := CASH_FUEL_DISC_NO;
//        Open;
//        if (RecordCount > 0) then
//          CashFuelDiscPerGallon := FieldByName('Amount').AsCurrency;
//        Close();
//      end;  // with
//      if POSDataMod.IBTransaction.InTransaction then
//        POSDataMod.IBTransaction.Commit;
//    except
//      CashFuelDiscPerGallon := 0.0;
//      UpdateExceptLog('ProcessKeyMED - Cannot determine cash fuel discount amount');
//    end;
    if (CashMediaApplied > 0.0) then
    begin
      nAmountSave := nAmount;
      ApplyDiscount(CASH_FUEL_DISC_NO, 'DS$', CashMediaApplied);
      nAmount := nAmountSave;
    end;
  end;  // if (MedRecType = CASH_MEDIA_TYPE)
  {$ENDIF}

  if (Media.MEDIANO <> NULL_MEDIA_NUMBER) then
    bOpenDrawer := Media.OpenDrawer;

  //Code moved below to account for food stamp adjustment of totals
  (*//XMD
  if abs(nAmount) >= abs(nCurAmountDue) then
  begin
    if bXMDActive then
    begin
      XMDFrame.XMDIssueCode;
      XMDFrame.XMDRedeemCode;
    end;
    //Kiosk
    if bKioskActive then
      KioskFrame.KioskComplete;
    //Kiosk
  end;
  //XMD*)
  
  // so we need to make it not equal
  if (Media.MEDIANO <> NULL_MEDIA_NUMBER) then
  begin
    sd := AddMediaList(@Media);
    DisplaySaleDataToPinPad(PPTrans, sd);
    PoleMedia(sd);
  end;
  //20040827...
  // Food stamp media requires a recomputation of sales tax.
  if (Media.RecType in [FOOD_STAMP_MEDIA_TYPE, EBT_FS_MEDIA_TYPE]) then
  begin
    ClearEntryField;
    CheckSaleList;
  end;
  //...20040827

  //XMD
  if abs(nAmount) >= abs(curSale.nAmountDue) then
  begin
    //Kiosk
    if bKioskActive then
      KioskFrame.KioskComplete;
    //Kiosk

      // Verify enough qualifying media has been tendered for any money orders purchased
      if (Media.MediaNo = CASH_MEDIA_NUMBER) then
        QualifiedMoneyOrderMedia := nAmount
      else
        QualifiedMoneyOrderMedia := 0.0;
      TotalMoneyOrderAmount := 0.0;
      for ndx := 0 to CurSaleList.Count - 1 do
      begin
        sd := CurSaleList.Items[ndx];
        if ((sd^.LineType = 'MED') and (sd^.Number = CASH_MEDIA_NUMBER)) then
          QualifiedMoneyOrderMedia := QualifiedMoneyOrderMedia + sd^.ExtPrice
        else if (fmMO.MOLine(sd)) then
          TotalMoneyOrderAmount := TotalMoneyOrderAmount + sd^.ExtPrice;
      end;
      if ((abs(QualifiedMoneyOrderMedia) < abs(TotalMoneyOrderAmount)) and (TotalMoneyOrderAmount <> 0.0)) then
      begin
        PosError('Must use cash to pay for money order');
        exit;
      end;
      // Check to see if money orders need to be printed.
      if Setup.MOSystem and (CurSaleList.Count > 0) then
      begin
        nAmountSave := nAmount;
        fmMO.SaleList := @CurSaleList;
        fmMO.TransNo := curSale.nTransNo;
        if fmMO.NeedToPrint then
        begin
          fmMO.ShowModal;
          fmMO.CleanSaleList();
          SendMOSMessage(BuildTag(TAG_MOCMD, IntToStr(CMD_MOPOST)));
          //ComputeSaleTotal();
          //nAmount := nAmountSave;
        end;
          ComputeSaleTotal();
          nAmount := nAmountSave;
      end;

    // Determine if any products need to be activated (after last tender).  If so,
    // then queue any remaining activation requests.
    if (IsActivationQueued()) then
    begin
      fmPOSMsg.ShowMsg('Attempting Activation...', 'Please Wait');
      for ndx := 0 to CurSaleList.Count - 1 do
      begin
        sd := CurSaleList.Items[ndx];
        if ((sd^.ActivationState = asActivationNeeded) and (not sd^.LineVoided)) then
        begin
          FCardActivationTimeOut := Now() + PRODUCT_ACTIVATION_TIMEOUT_DELTA;
          QueueActivationRequest(sd);
        end;
      end;
      exit;  // This procedure called again to finalize sale after last activation attempt.
    end;
  end;
  //XMD

  UpdateZLog('ProcessKeyMED - nAmount: %.2f, nCurAmountDue: %.2f, bPostTender: %s', [nAmount, curSale.nAmountDue, booltoStr(bPostTender,True)]);
  if (abs(nAmount) >= abs(curSale.nAmountDue))
     or (bPostTender and (nAmount = 0) and (curSale.nAmountDue < 0)) then
    Self.FinalizeSale()
  else
  begin
    curSale.nMedia := curSale.nMedia + nAmount;
    if ((curSale.nAmountDue < 0) and (nAmount < 0) and
        ((not lbReturn.Visible) or
         ((Media.MediaNo <> COUPON_MEDIA_NUMBER) and (not bPostTender)))) then
      curSale.nAmountDue := curSale.nAmountDue + nAmount
    else
      curSale.nAmountDue := curSale.nAmountDue - nAmount;
    lTotal.Caption := 'Amount Due';
    eTotal.Text := Format('%12s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nAmountDue))]);
    SetNextDollarKeyCaption;
   //  If Pinpad configured and amount still due after credit tender, then reset pin pad transaction.
    if ((PPTrans <> nil) and (curSale.nAmountDue > 0) and bCCUsed) then
    begin
      AssignTransNo();
      PPTrans.TransNo := curSale.nTransNo;
      ReComputeSaleTotal(False);
  end;
  end;
   //ShowMessage('before : ClearEntryField'); // madhu remove
  ClearEntryField;
end;


function TfmPOS.NullIntToStr(aInt : Integer) : String;
var
   rSult : String;
begin
   rSult := IntToStr(aInt);
   if (Trim(rSult) = '') then
      rSult := '"Null"';
   result := rSult;
end;

procedure TfmPOS.CreateJsonFromReceiptList();
var
   ReceiptJsonObj : String;
   JsonReceiptData : pSalesData;
   ArrX : Integer;
   ndx : Integer;
begin
   // here is where we would build the json object to pass to the API
    // we use the receipt list and will currently just export it to ZLOG
    // Michael Stith
    try
      for ndx := 0 to ReceiptList.Count - 1 do
      begin
         ReceiptJsonObj := '';
         ReceiptData := ReceiptList.Items[ndx];
         ReceiptJsonObj := '{';
         ReceiptJsonObj := ReceiptJsonObj + '"SeqNumber":' + NullIntToStr(ReceiptData^.SeqNumber) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"LineType":"' + ReceiptData^.LineType + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"SaleType":"' + ReceiptData^.SaleType + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"Number":' + FormatFloat('#######0.##',ReceiptData^.Number) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"Name":"' + ReceiptData^.Name + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"Qty":' + FormatFloat('#######0.##',ReceiptData^.Qty) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"Price":' + FormatFloat('#######0.##',ReceiptData^.Price) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"ExtPrice":' + FormatFloat('#######0.##',ReceiptData^.ExtPrice) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"SavDiscType":"' + ReceiptData^.SavDiscType + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"SavDiscable":' + FormatFloat('#######0.##',ReceiptData^.SavDiscable) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"SavDiscAmount":' + FormatFloat('#######0.##',ReceiptData^.SavDiscAmount) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"FuleSaleID":' + NullIntToStr(ReceiptData^.FuelSaleID) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"PumpNo":' + NullIntToStr(ReceiptData^.PumpNo) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"HoseNo":' + NullIntToStr(ReceiptData^.HoseNo) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"TaxNo":' + NullIntToStr(ReceiptData^.TaxNo) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"TaxRate":' + FormatFloat('#######0.##',ReceiptData^.TaxRate) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"Taxable":' + FormatFloat('#######0.##',ReceiptData^.Taxable) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"Discable":"' + BoolToStr(ReceiptData^.Discable,True) + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"FoodStampable":"' + BoolToStr(ReceiptData^.FoodStampable,True) + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"FoodStampApplied":' + FormatFloat('#######0.##',ReceiptData^.FoodStampApplied) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"LineVoided":"' + BoolToStr(ReceiptData^.LineVoided,True) + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"AutoDisc":"' + BoolToStr(ReceiptData^.AutoDisc,True) + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"PriceOverridden":"' + BoolToStr(ReceiptData^.PriceOverridden,True) + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"PLUModifier":' + NullIntToStr(ReceiptData^.PLUModifier) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"PLUModifierGroup":' + FormatFloat('#######0.##',ReceiptData^.PLUModifierGroup) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"DeptNo":' + NullIntToStr(ReceiptData^.DeptNo) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"VendorNo":' + NullIntToStr(ReceiptData^.VendorNo) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"ProdGrpNo":' + NullIntToStr(ReceiptData^.ProdGrpNo) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"LinkedPLUNo":' + FormatFloat('#######0.##',ReceiptData^.LinkedPLUNo) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"SplitQty":' + NullIntToStr(ReceiptData^.SplitQty) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"SplitPrice":' + FormatFloat('#######0.##',ReceiptData^.SplitPrice) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"QtyUsedForSplitOrMM":' + NullIntToStr(ReceiptData^.QtyUsedForSplitOrMM) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"ItemNo":' + FormatFloat('#######0.##',ReceiptData^.ItemNo) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"WexCode":' + NullIntToStr(ReceiptData^.WexCode) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"PHHCode":' + NullIntToStr(ReceiptData^.PHHCode) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"IAESCode":' + NullIntToStr(ReceiptData^.IAESCode) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"VoyagerCode":' + NullIntToStr(ReceiptData^.VoyagerCode) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCAuthCode":"' + ReceiptData^.CCAuthCode + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCApprovalCode":"' + ReceiptData^.CCApprovalCode + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCDate":"' + ReceiptData^.CCDate + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCTime":"' + ReceiptData^.CCTime + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCCardNo":"' + ReceiptData^.CCCardNo + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCPhoneNo":"' + ReceiptData^.CCPhoneNo + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCCardName":"' + ReceiptData^.CCCardName + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCCardType":"' + ReceiptData^.CCCardType + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCExpDate":"' + ReceiptData^.CCExpDate + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCBatchNo":"' + ReceiptData^.CCBatchNo + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCSeqNo":"' + ReceiptData^.CCSeqNo + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCEntryType":"' + ReceiptData^.CCEntryType + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCVehicleNo":"' + ReceiptData^.CCVehicleNo + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCOdometer":"' + ReceiptData^.CCOdometer + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCVehicleID":"' + ReceiptData^.CCVehicleID + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCRetrievalRef":"' + ReceiptData^.CCRetrievalRef + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCAuthNetID":"' + ReceiptData^.CCAuthNetId + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCAuthorizer":"' + ReceiptData^.CCAuthorizer + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCTraceAuditNo":"' + ReceiptData^.CCTraceAuditNo + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCCPSData":"' + ReceiptData^.CCCPSData + '",';
         //CCPrintLine     : array[1..4] of string[80];
         ReceiptJsonObj := ReceiptJsonObj + '"CCPrintLine":[';
         for ArrX := low(ReceiptData^.CCPrintLine) to high(ReceiptData^.CCPrintLine) do
         begin
          if (Trim(ReceiptData^.CCPrintLine[ArrX]) <> '') then
             ReceiptJsonObj := ReceiptJsonObj + '"' + ReceiptData^.CCPrintLine[ArrX] + '",';
         end;
         if (Copy(ReceiptJsonObj,Length(ReceiptJsonObj),1) = ',') then
            ReceiptJsonObj := Copy(ReceiptJsonObj,1,Length(ReceiptJsonObj) - 1);
         ReceiptJsonObj := ReceiptJsonObj + '],';
         ReceiptJsonObj := ReceiptJsonObj + '"CCBalance1":' + FormatFloat('#######0.##',ReceiptData^.CCBalance1) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCBalance2":' + FormatFloat('#######0.##',ReceiptData^.CCBalance2) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCBalance3":' + FormatFloat('#######0.##',ReceiptData^.CCBalance3) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCBalance4":' + FormatFloat('#######0.##',ReceiptData^.CCBalance4) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCBalance5":' + FormatFloat('#######0.##',ReceiptData^.CCBalance5) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCBalance6":' + FormatFloat('#######0.##',ReceiptData^.CCBalance6) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCRequestType":' + NullIntToStr(ReceiptData^.CCRequestType) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCAuthId":' + NullIntToStr(ReceiptData^.CCAuthId) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"CCPartialTend":"' + BoolToStr(ReceiptData^.CCPartialTend,True) + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"CCHost":' + NullIntToStr(ReceiptData^.CCHost) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"GiftCardRestrictionCode":' + NullIntToStr(ReceiptData^.GiftCardRestrictionCode) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"GiftCardStatus":' + NullIntToStr(ReceiptData^.GiftCardStatus) + ',';

         ReceiptJsonObj := ReceiptJsonObj + '"GCMSRData":[';
         for ArrX := 0 to 200 do
         begin
            if (Trim(ReceiptData^.GCMSRData[ArrX]) <> '') then
            begin
               ReceiptJsonObj := ReceiptJsonObj + '"' + ReceiptData^.GCMSRData[ArrX] + '",';
            end;
         end;
         if (Copy(ReceiptJsonObj,Length(ReceiptJsonObj),1) = ',') then
            ReceiptJsonObj := Copy(ReceiptJsonObj,1,Length(ReceiptJsonObj) - 1);
         ReceiptJsonObj := ReceiptJsonObj + '],';
       
         ReceiptJsonObj := ReceiptJsonObj + '"SeqLink":' + NullIntToStr(ReceiptData^.SeqLink) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"MODocNo":"' + ReceiptData^.MODocNo + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"NeedsActivation":"' + BoolToStr(ReceiptData^.NeedsActivation,True) + '",';
       
         ReceiptJsonObj := ReceiptJsonObj + '"ActivationState":' + NullIntToStr(Ord(ReceiptData^.ActivationState)) + ',';
       
         ReceiptJsonObj := ReceiptJsonObj + '"ActivationTransNo":' + NullIntToStr(ReceiptData^.ActivationTransNo) + ',';
       
         ReceiptJsonObj := ReceiptJsonObj + '"ActivationTimeout":"' + FormatDateTime('MM/DD/YYYY HH:MI:SS', ReceiptData^.ActivationTimeout) + '",';
       
         ReceiptJsonObj := ReceiptJsonObj + '"LineId":' + NullIntToStr(ReceiptData^.LineID) + ',';
         ReceiptJsonObj := ReceiptJsonObj + '"ccPIN":"' + ReceiptData^.ccPIN + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"ReceiptText":"' + ReceiptData^.receipttext + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"MediaRestrictonCode":' + NullIntToStr(ReceiptData^.mediarestrictioncode) + ',';
         //ReceiptJsonObj := ReceiptJsonObj + '"EMVAuthConf":"' + ReceiptData^.emvauthconf + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"TransactionDate":"' + FormatDateTime('MM/DD/YYYY', Now) + '",';
         ReceiptJsonObj := ReceiptJsonObj + '"TransactionTime":"' + FormatDateTime('HH:MI:SS', Now) + '"';
         ReceiptJsonObj := ReceiptJsonObj + '}';
         UpdateZLog(ReceiptJsonObj);
         //ReceiptData^
      end;
    except
       on E : Exception do
       begin
          UpdateZLog(E.Message);
       end;
    end;
end;

procedure TfmPOS.FinalizeSale();
var
  ndx : integer;
  sd : pSalesData;
  CCMsg : string;
  idxFirstMediaLine : integer;
  bCarwashPurchased : boolean;
  bActivationProductPurchased : boolean;
  bDeactivateProductFailed : boolean;
  {$IFDEF FUEL_FIRST}
  bDriveOffTender : boolean;
  nDepartmentNumber : integer;
  nCATGrade : integer;
  sCATGradeName : string;
  pDriveOffSaleData : pSalesData;                                                //20060718b
  {$ENDIF}
  {$IFDEF FF_PROMO}
  FFCPSData : string;
  FFCouponCount : integer;
  FuelFirstCouponCount : integer;
  FuelFirstCardNo : string;
  FuelFirstCouponAuthID : integer;
  {$ENDIF}
  
begin
  UpdateZLog('inside : FinalizeSale function-tarang');
 // ShowMessage('inside : FinalizeSale function'); // madhu remove
  {$IFDEF FF_PROMO}
  FuelFirstCouponCount := 0;
  FuelFirstCouponAuthID := 0;
  {$ENDIF}

    if Setup.MOSystem then
    begin
      fmMO.SaleList := @CurSaleList;
      fmMO.TransNo := curSale.nTransNo;
      if fmMO.NeedToVoid then
      begin
        fmMO.Void;
        SendMOSMessage(BuildTag(TAG_MOCMD, IntToStr(CMD_MOPOST)));
      end;
    end;

    bPostingSale := True;
    curSale.nChangeDue := - curSale.nAmountDue;
    UpdateZLog('FinalizeSale - posting sale - nAmount: %.2f, nCurAmountDue: %.2f, nCurChangeDue: %.2f',[nAmount, curSale.nAmountDue, curSale.nChangeDue]);
    lTotal.Caption := 'Your Change';
    eTotal.Text := Format('%12s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nChangeDue))]);
    lTotal.Refresh;
    eTotal.Refresh;

    {$IFDEF FUEL_FIRST}
    // Check to see if this is a drive-off for a Fuel First customrer.

    bDriveOffTender := False;  // Initial assumption.
    pDriveOffSaleData := nil;                                                    //20060718b
    for ndx := 0 to (CurSaleList.Count - 1) do
    begin
      sd := CurSaleList.Items[ndx];
      if ((sd^.LineType = 'MED') and
//          (not CurSaleData^.LineVoided) and
          (sd^.Number = DRIVE_OFF_MEDIA_NUMBER)) then
      begin
        bDriveOffTender := True;
        pDriveOffSaleData := sd;                                        //20060718b
        break;
      end;
    end;
    {$IFDEF FF_PROMO}
    // Look for any Fuel First sales so that the credit server can be notified about the completion.
    {$ELSE}
    // If this is a "drive off" tender, then notify the credit server of any Fuel First customer sales
    //(so that a report can be queued to the Fuel First Host).
    if (bDriveOffTender) then
    begin
    {$ENDIF}
      for ndx := 0 to (CurSaleList.Count - 1) do
      begin
        sd := CurSaleList.Items[ndx];
        if ((sd^.LineType = 'FUL') and
//20061107a            (CurSaleData^.CCCardType = CT_FUEL_FIRST) and
            (sd^.SaleType <> 'Void') and
            (not sd^.LineVoided)) then
        begin
          //20061107a...
          // Need to just check for a Fuel First authorization, but under some stacked sales
          // situations, the fuel server does not pass the card type, so the AuthID (CCAuthorizer)
          // is used to determine the card type.
          if ((sd^.CCCardType = CT_FUEL_FIRST) or (sd^.CCAuthID > 0)) then
          begin
          //...20061107a

            // The sales item for the fuel was located:
            // Determine the CAT grade from the department number of the sale item.

            nDepartmentNumber := round(sd^.Number);  // Used by credit server to determine fuel grade.
            {$IFDEF FF_PROMO}
            FuelFirstCardNo := '';
            {$ENDIF}
            try
            if not POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.StartTransaction;
            with POSDataMod.IBTempQuery do
            begin
              Close;
              SQL.Clear;
              SQL.Add('Select GradeNo, Name from Grade where DeptNo = :pDeptNo');
              ParamByName('pDeptNo').AsInteger := nDepartmentNumber;
              Open;
              if (RecordCount > 0) then
              begin
                nCATGrade := FieldByName('GradeNo').AsInteger;
                sCATGradeName := FieldByName('Name').AsString;
              end
              else
              begin
                UpdateExceptLog('ProcessKeyMed - No FF grade for dept:  ' + IntToStr(nDepartmentNumber));
                nCATGrade := 1;   // Go ahead queue the drive-off report with an assumed fuel grade.
                sCATGradeName := 'UNKNOWN';
              end;
              //20060718b...
              // Change the receipt line to indicate a "Fuel First Drive Off"
              {$IFNDEF FF_PROMO}
              if (pDriveOffSaleData <> nil) then
              {$ENDIF}
              begin
                Close;
                SQL.Clear;
                //20061107a...
//                SQL.Add('Select CardNo from ccAuth where AuthID = :pAuthID');
                SQL.Add('Select CardType, CardNo from ccAuth where AuthID = :pAuthID');
                //...20061107a
                ParamByName('pAuthID').AsInteger := sd^.CCAuthID;
                Open;
                if (RecordCount > 0) then
                begin
                  if (Trim(sd^.CCCardType) = '') then
                    sd^.CCCardType := (FieldByName('CardType').AsString);
                  //20061107a...
                  if ((sd^.CCCardType = CT_FUEL_FIRST)
                      {$IFDEF FF_PROMO}
                      and (pDriveOffSaleData <> nil)
                      {$ENDIF}
                                                               ) then
                  //...20061107a
                    pDriveOffSaleData^.Name := Copy(FieldByName('CardNo').AsString, 7, 10) +
                                               ' ' + Copy(pDriveOffSaleData^.Name, 1, 9);
                    {$IFDEF FF_PROMO}
                    FuelFirstCardNo := Trim(FieldByName('CardNo').AsString);
                    {$ENDIF}
                end
                //20061107a...
//                else
                else if ((sd^.CCCardType = CT_FUEL_FIRST)
                         {$IFDEF FF_PROMO}
                         and (pDriveOffSaleData <> nil)
                         {$ENDIF}
                                                                  ) then
                //...20061107a
                begin
                  pDriveOffSaleData^.Name := 'Fuel First ' + Copy(pDriveOffSaleData^.Name, 1, 9);
                end
              end;
              //...20060718b
              close;
            end;
            if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Commit;
            except
              UpdateExceptLog('ProcessKeyMed - Could not determine FF grade for dept:  ' + IntToStr(nDepartmentNumber));
              nCATGrade := 1;   // Go ahead queue the drive-off report with an assumed fuel grade.
              sCATGradeName := 'UNKNOWN';
            end;

            if (sd^.CCCardType = CT_FUEL_FIRST) then                   //20061107a
            begin                                                               //20061107a
              // Notify the credit server (with a special "collect" message) about the drive-off.

              {$IFDEF FF_PROMO}
              // "CPS" field is used by credit server to determine if transaction is a driveoff
              if (bDriveOffTender) then
                FFCPSData := CPS_DRIVEOFF
              else
                FFCPSData := '';
              {$ENDIF}
              ccMSG := BuildTag(TAG_MSGTYPE, IntToStr(CC_DATACOLLECT)) +
                       BuildTag(TAG_TRANSNO, IntToStr(curSale.nTransNo)) +
                       BuildTag(TAG_CARDTYPE, sd^.CCCardType) +
                       BuildTag(TAG_AUTHID, IntToStr(sd^.CCAuthID)) +
                       {$IFDEF FF_PROMO}
                       BuildTag(TAG_CPSDATA, FFCPSData) + // Indicates if drive-off occured
                       {$ENDIF}
                       BuildTag(TAG_CATGRADE, IntToStr(nCATGrade)) +
                       BuildTag(TAG_PUMPNO, IntToStr(sd^.PumpNo)) +
                       BuildTag(TAG_GRADE_NAME, sCATGradeName) +
                       BuildTag(TAG_CATVOLUME, CurrToStr(sd^.Qty )) +
                       BuildTag(TAG_CATUNITPRICE, CurrToStr(sd^.Price )) +
                       BuildTag(TAG_FUELAMOUNT, CurrToStr(sd^.ExtPrice ));
              SendCreditMessage(CCMsg);
              {$IFDEF FF_PROMO}
              // Count any awarded coupons (if any coupons detected, then receipt is printed
              // below regardless of other "print receipt" settings).
              FFCouponCount := 0;
              try
                POSPrt.PrintFuelFirstCoupon(sd^.CCAuthID, False, FFCouponCount);
              except
                FFCouponCount := 0;
              end;
              if (FFCouponCount > 0) then
                FuelFirstCouponAuthID := sd^.CCAuthID;  // (note) - Only one FF award (last in sales list) is printed below.
              {$IFDEF FF_PROMO_20080128}
              if VerifyFuelFirstCard(FuelFirstCardNo) then
              {$ENDIF}  // FF_PROMO_20080128
                Inc(FuelFirstCouponCount, FFCouponCount);
              {$ENDIF}
            end;  // if (CurSaleData^.CCCardType = CT_FUEL_FIRST)               //20061107a
          end;  // if ((CurSaleData^.CCCardType = CT_FUEL_FIRST) or (CurSaleData^.CCAuthorizer > 0))  //20061107a
        end;  // if fuel entry
      end;  // for ndx := 0 to (CurSaleList.Count - 1)
    {$IFNDEF FF_PROMO}
    end;  // if (bDriveOffTender)
    {$ENDIF}  // FF_PROMO
    {$ENDIF}  // FUEL_FIRST

    //Build 31
    PinCreditSelect := 0;

    if curSale.nChangeDue <> 0 then
      bOpenDrawer := True;

    if (bCoinDispenserActive = 1) and (curSale.nChangeDue <> 0 )then
    begin
      try
        ChangeCents := StrToInt('$'+ IntToStr(Round(frac(Abs(curSale.nChangeDue)) * 100 )));
        ChangeOutBuff[0] := ChangeCents;
        ChangeOutBuff[1] := ChangeOutBuff[0] xor $ff;
        CoinPort.Open := True;
        CoinPort.PutBlock(ChangeOutBuff, 2);
        CoinPort.Open := False;
      except
        UpdateExceptLog('Coin changer error');
      end;
    end;

    {$IFDEF TIMING_DEBUG} UpdateZLog('ProcessKeyMED: About to pop drawer'); {$ENDIF}
    if bOpenDrawer then
    begin
      OpenDrawer;
      dTillOpenTime := Now;
    end;

    if bPlayWave then
      PlaySound( 'OPENDWR', HInstance, SND_ASYNC or SND_RESOURCE) ;

    PoleChange(curSale.nChangeDue, curSale.nTotal);
    nTimerCount := 0;

    EmptyReceiptList;

    // Move current sales data to the receipt list
    // (but move 'media' lines to the end).
    idxFirstMediaLine := 0;
    for ndx := 0 to (CurSaleList.Count - 1) do
    begin
      sd    := CurSaleList.Items[ndx];
      if (sd^.LineType = 'MED') then
      begin
        if (idxFirstMediaLine = 0) then
          idxFirstMediaLine := ndx;      // Save location of first media line (no need to search above this line for media)
      end
      else
      begin
        New(ReceiptData);
        ReceiptData^   := sd^;
        ReceiptData^.receipttext := sd^.receipttext;
        ReceiptList.Capacity := ReceiptList.Count;
        ReceiptList.Add(ReceiptData);
      end;
    end;
    for ndx := idxFirstMediaLine to (CurSaleList.Count - 1) do
    begin
      sd    := CurSaleList.Items[ndx];
      if (sd^.LineType = 'MED') then
      begin
        New(ReceiptData);
        ReceiptData^   := sd^;
        ReceiptData^.receipttext := sd^.receipttext;
        ReceiptList.Capacity := ReceiptList.Count;
        ReceiptList.Add(ReceiptData);
      end;
    end;

    rcptSale.nFSSubtotal  := curSale.nFSSubtotal;
    rcptSale.nSubtotal    := curSale.nSubtotal;
    rcptSale.nTlTax       := curSale.nTlTax;
    rcptSale.bSalesTaxXcpt     := curSale.bSalesTaxXcpt;
    rcptSale.nTotal       := curSale.nTotal;
    rcptSale.nChangeDue   := curSale.nChangeDue;
    rcptSale.nTransNo     := curSale.nTransNo;
    nRcptShiftNo     := nShiftNo;

    PostSaleList.Clear;
    PostSaleList.Capacity := PostSaleList.Count;
    //XMD
    bXMDEarned := False;
    //XMD

    //cwa...
    // Move "current" sales list to "post" sales list and
    //  determine if any carwashes were purchased.
    bCarwashPurchased := False;  // Initial assumption
    //...cwa
    bActivationProductPurchased := False;  // Initial assumption
    bDeactivateProductFailed := False;  // Initial assumption
    for ndx := 0 to (CurSaleList.Count - 1) do
    begin
      //cwa...
      if (GetCarwashAccessCode(CurSaleList.Items[ndx]) <> '') then
          bCarwashPurchased := True;
      //...cwa
      if (pSalesData(CurSaleList.Items[ndx]).NeedsActivation) then
      begin
        bActivationProductPurchased := True;
        sd := CurSaleList.Items[ndx];
        if ((sd^.SaleType = 'Void') and (sd^.ExtPrice < 0.0) and
            (not (sd^.ActivationState in [asActivationDoesNotApply, asActivationRejected]))) then
          bDeactivateProductFailed := True;
      end;
      //XMD
      if GetXMDEarned(CurSaleList.Items[ndx]) <> '' then
        bXMDEarned := True;
      //XMD
      PostSaleList.Capacity := PostSaleList.Count;
      PostSaleList.Add(CurSaleList.Items[ndx]);
    end;

    pstSale.nNonTaxable      := curSale.nNonTaxable;
    pstSale.nFSSubtotal      := curSale.nFSSubtotal;
    pstSale.nSubtotal        := curSale.nSubtotal;
    pstSale.nTlTax           := curSale.nTlTax;
    pstSale.bSalesTaxXcpt    := curSale.bSalesTaxXcpt;
    pstSale.nTotal           := curSale.nTotal;
    //Gift
    pstSale.nMedia           := curSale.nMedia;
    //Gift
    pstSale.nChangeDue       := curSale.nChangeDue;
    pstSale.nTransNo         := curSale.nTransNo;
    pstSale.nDiscountableTl  := curSale.nDiscountableTl;
    pstSale.nFSChange        := curSale.nFSChange;
    pstSale.nAmountDue       := curSale.nAmountDue;

    {$IFDEF TIMING_DEBUG} UpdateZLog('ProcessKeyMED: Processing Sales Tax'); {$ENDIF}
    //20041215...
    EnterCriticalSection(CSTaxList);  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    try // PROGRAMMING WARNING:  Do not exit this try block without leaving critical section.
    //...20041215 (following block indented as part of change)
      for ndx := 0 to (CurSalesTaxList.Count - 1) do
      begin
        CurSalesTax  := CurSalesTaxList.Items[ndx];
        PostSalesTax := PostSalesTaxList.Items[ndx];
        PostSalesTax^.TaxNo      := CurSalesTax^.TaxNo;
        PostSalesTax^.Taxable    := CurSalesTax^.Taxable;
        PostSalesTax^.TaxQty     := CurSalesTax^.TaxQty;
        PostSalesTax^.TaxCharged := CurSalesTax^.TaxCharged;
        //20040908...
        PostSalesTax^.FSTaxExemptSales  := CurSalesTax^.FSTaxExemptSales;
        PostSalesTax^.FSTaxExemptAmount := CurSalesTax^.FSTaxExemptAmount;
        //...20040908
      end;
    //20041215... (previous block indented as part of change)
    except
    end; // try/except
    LeaveCriticalSection(CSTaxList);  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    //...20041215
      //ShowMessage('PostSale(PostSaleList)'); // madhu remove
    UpdateZLog('ProcessKeyMed: PostSale');
    POSPost.PostSale(PostSaleList);

      //ShowMessage('SaveSale(PostSaleList)'); // madhu remove
    UpdateZLog('ProcessKeyMed: SaveSale');
    Receipt.SaveSale(PostSaleList);

      //ShowMessage('SaveSaleToText(PostSaleList)'); // madhu remove
    UpdateZLog('ProcessKeyMed: SaveSaleToText');
    Receipt.SaveSaleToText(PostSaleList);

     // ShowMessage('LogSale(PostSaleList)'); // madhu remove
    UpdateZLog('ProcessKeyMed: LogSale');
    POSLog.LogSale(PostSaleList);

    UpdateZLog('ProcessKeyMed: LogSale done');

    DisposeSalesListItems(PostSaleList); // Items on PostSaleList are same as on CurSaleList, so this disposes both.

    CurSaleList.Clear;
    CurSaleList.Capacity := CurSaleList.Count;
    PostSaleList.Clear;
    PostSaleList.Capacity := PostSaleList.Count;
    pstSale.nNonTaxable      := 0;
    pstSale.nFSSubtotal      := 0;
    pstSale.nSubtotal        := 0;
    pstSale.nTlTax           := 0;
    pstSale.nTotal           := 0;
    pstSale.nChangeDue       := 0;
    pstSale.nTransNo         := 0;
    pstSale.nDiscountableTl  := 0;
    pstSale.nFSChange        := 0;
    pstSale.nAmountDue       := 0;

    // Michael Stith Uncomment to Create JSON objects
    //CreateJsonFromReceiptList();
    
    if bCCUsed then
    begin
      bSignatureRequired := CheckReceiptListForSignatureRequired(ReceiptList);
      CCSecond := False;
      if (bSignatureRequired) then
      begin
      //ShowMessage('PrintReceiptFromReceiptList'); // madhu remove
      UpdateZLog('PrintReceiptFromReceiptList-tarang');
      PrintReceiptFromReceiptList(ReceiptList);
      end;
      CCSecond := True;
      //Gift
      bGiftCardReceiptInfoFollows := ((qClient^.GiftCardUsedList.Count > 0) or
        (qClient^.GiftCardActivateList.Count > 0));
      //Gift
      PrintReceiptFromReceiptList(ReceiptList);
      CCSecond := False;
      if (not bDeactivateProductFailed) then
        EmptyReceiptList;
    End
    else if SaleState = ssBankFuncTender then
    begin
      PrintReceiptFromReceiptList(ReceiptList);
      EmptyReceiptList;
      nTimerCount := 95;
    end
    //XMD
    //else if ((POST_PRINT) or bCarwashPurchased) then
    else if ((POST_PRINT)
             or bCarwashPurchased
             or bActivationProductPurchased
             {$IFDEF FF_PROMO}
             or (FuelFirstCouponCount > 0)
             {$ENDIF}
             or bXMDEarned) then
    begin
      PrintReceiptFromReceiptList(ReceiptList);
      if (not bDeactivateProductFailed) then
      EmptyReceiptList;
    end;
    //Gift
    //20060626...
//    PrintGiftCardBalance(@(qClient^.GiftCardUsedList));
//    PrintGiftCardBalance(@(qClient^.GiftCardActivateList));
    if (nCreditAuthType = CDTSRV_BUYPASS) then
    begin
      PrintGiftCardBalance(@(qClient^.GiftCardUsedList), '**** Gift Card Information ****', '');
    end
    else
    begin
      PrintGiftCardBalance(@(qClient^.GiftCardUsedList), '**** Gift Card Information ****', '');
    end;
    //...20060626
    //Gift

    {$IFDEF FF_PROMO}
    // Check for any awarded Fuel First coupons
    if ((FuelFirstCouponCount > 0) and (not bDriveOffTender)) then
    begin
      try
        POSPrt.PrintFuelFirstCoupon(FuelFirstCouponAuthID, True, FFCouponCount);
      except
      end;
    end;  // if (FuelFirstCouponCount > 0)
    {$ENDIF}
    // If any deactivation attempt of products failed, then print extra receipt showing products.
    if (bDeactivateProductFailed) then
    begin
      PrintFailedActivationFromReceiptList(ReceiptList);
      EmptyReceiptList;
      PrintSeq();
    end;

    bSaleComplete := True;
    bPostingSale := False;

    SaleState := ssNoSale;

    if bCompulseDwr then
    begin
      CloseDrawer;
      if nTillTimer > 0 then  // if a till timeout is defined
      begin
        if TimerExpired(dTillOpenTime, nTillTimer) then
        begin
          IncrementTillTimeout(dTillOpenTime, nTillTimer);
        end;
      end;
    end;

    if OverDrawerLimit then
      fmPos.POSError('Make That Drop !!!');
    SetNextDollarKeyCaption;
    lbReturn.Visible := False;

    nCurMenu := 0;
    UpdateZLog('DisplayMenu(nCurMenu)-tarang');
   // ShowMessage('DisplayMenu(nCurMenu)'); // madhu remove
    DisplayMenu(nCurMenu);
    bCaptureNFPLU := False;
    bNeedModifier := False;
    if bMSRActive = 2 then
    begin
      if CheckNCRMSR(MSROPOSName) then
      begin
        OPOSMSR.DeviceEnabled := True;
        OPOSMSR.DataEventEnabled := True;
      end;
    end;

    //PPTrans.SendAdRequest(1);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCOP
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCOP();
var
pNo :short;
begin

  if sEntry = '' then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;

  nAmount := StrToFloat(sEntry);
  if not (nAmount > 0) then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;
  nAmount := nAmount / 100 ;

  if (nAmount > 200) then
    begin
      POSError('Over High Amount Limit');
      Exit;
    end;
  nAmount := POSRound(nAmount, 2);

  if not (SaleState in [ssTender, ssBankFuncTender ]) then
    curSale.nAmountDue := POSRound(curSale.nTotal,2);

  if (curSale.nAmountDue >= nAmount) or (curSale.nAmountDue < 0) then
    begin
      POSError('No Change For Gas');
      ClearEntryField;
      Exit;
    end;

  if sPumpNo = '' then
    begin
      POSError('Please Select A Pump');
      ClearEntryField;
      Exit;
    end;
  pNo := StrToInt(sPumpNo);

  SendFuelMessage( pNo, PMP_RESERVECOP, nAmount - curSale.nAmountDue, NOSALEID, NOTRANSNO, NODESTPUMP );

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessCOP
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TWMCOP
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessCOP(var Msg: TWMCOP);
var
  PumpNo : integer;
  PrePayAmount : currency;
  SD : pSalesData;
begin

  PumpNo := (Msg.COPInfo.PumpNo);
  PrepayAmount := (Msg.COPInfo.PrePayAmount);
  Dispose(Msg.COPInfo);

  if SaleState = ssNoSale then
    AssignTransNo;

  nPumpNo     := PumpNo;
  nAmount     := PrePayAmount;
  nPumpAmount := PrePayAmount;
  nPumpVolume := 0;
  nPumpSaleID := 0;

  nQty      := 1;
  SaleState := ssSale;
  sLineType := 'PPY';
  sSaleType := 'Sale';

  SD := AddSaleList;

  PoleMdse(SD, SaleState);

  ComputeSaleTotal;
  ClearEntryField;
  nPumpNo := 0;

  //ProcessKeyMed('COP', '1', Preset, False, False);

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.OverDrawerLimit
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    Boolean
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.OverDrawerLimit : Boolean;
begin

  OverDrawerLimit := False;

  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('SELECT Sum(M.DlySales) FROM MedShift M ' +
                          'where M.MediaNo = 1 And TerminalNo = ' + IntToStr(ThisTerminalNo) +
                          ' And ShiftNo = ' + IntToStr(nShiftNo)  );
      Open;
      if NOT EOF then
        begin
          if (Fields[0].AsCurrency  >= nDwrLimit) then
              OverDrawerLimit := True;
        end;

      Close;
      SQL.Clear;
    end;
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
end;

(* //cwe
// Used Only to Benchmark Posting Routines (Temp)
procedure TfmPOS.LogIt( sMsg: shortstring; iMs: Integer);
var
  LogName: shortstring;
  TF: TextFile;
begin
  LogName := ExtractFileDir(Application.ExeName) + '\LogIt02.Txt' ;
  AssignFile(TF, LogName);
  if FileExists(LogName) then
    Append(TF)
  else
    begin
      ReWrite(TF);
      WriteLn(TF, 'Trx#,Routine,Time(ms)');
    end;


  WriteLn( TF, IntToStr(nCurTransNo)+ ',' + sMsg + ',' + IntToStr(iMs) );
  CloseFile(TF);

end;
   //...cwe  *)

{-----------------------------------------------------------------------------
  Name:      TfmPOS.BeginToFinalize
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.BeginToFinalize();
var
  s: string;
  i : integer;
  taxname : string;
begin
   UpdateZLog(' Inside : BeginToFinalize funciton-tarang');
  //ShowMessage(' Inside : BeginToFinalize funciton');
  if curSale.bSalesTaxXcpt then
    taxname := 'Sales Tax Exempt'
  else
    taxname := 'Tax';
  if POSListBox.Items.Count >= 2 then
    begin

      if bUseFoodStamps then
        begin
          s := Format('%23s',['FS Subtotal']) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nFSSubtotal))]);
          POSListBox.Items.Strings[POSListBox.Items.Count - 3] := s;
        end;
      if Pos('Coupon',POSListBox.Items.Strings[POSListBox.Items.Count-1]) = 0 then
        i := 2 else i := 4;
      s := Format('%23s',['Subtotal']) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nSubtotal))]);
      POSListBox.Items.Strings[POSListBox.Items.Count - i] := s;
      dec(i);
      s := Format('%23s',[taxname]) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nTlTax))]);
      POSListBox.Items.Strings[POSListBox.Items.Count - i] := s;

      s := Format('%23s',['Total']) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nTotal))]);
      if Pos('Coupon',POSListBox.Items.Strings[POSListBox.Items.Count-1]) = 0 then
        POSListBox.Add(s)
      else curSale.nTotal := curSale.nAmountDue;

      POSListBox.Refresh;
      POSListBox.ItemIndex := POSListBox.Items.Count - 1;
    end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyBNK
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyBNK(const sKeyVal : string);
var
bOverLimit : boolean;
nCurDwrAmount : currency;
begin

  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBBankFuncQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Select * from BankFunc where BankNo = :pBankNo');
    try
      ParamByName('pBankNo').AsInteger := StrToInt(sKeyVal);
    except
      ParamByName('pBankNo').AsInteger := 0;
    end;
    Open;
    if not EOF then
    begin
      BankBANKNO := fieldbyname('BankNo').AsInteger;
      BankNAME := fieldbyname('Name').AsString;
      BankHALO := fieldbyname('HALO').AsCurrency;
      BankRECTYPE := fieldbyname('RecType').AsInteger;
      close;
    end
    else
    if EOF then
    begin
      close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      POSError('Bank Function Not Found');
      Exit;
    end;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  if sEntry = '' then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;

  try
    nAmount := StrToFloat(sEntry);
  except
    POSError('Invalid Numeric Entry');
    ClearEntryField;
    Exit;
  end;

  if nAmount = 0 then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;

  nAmount := nAmount / 100;

  bOverLimit := False;
  if BankRecType = 3 then  {3 = cash drop}
  begin
    nCurDwrAmount := 0;
    if (nUseStartingTill = STARTINGTILL_ENTER) or (nUseStartingTill = STARTINGTILL_DEFAULT) then
    begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('SELECT StartingTill from Totals ' +
          'where (TerminalNo = ' + IntToStr(ThisTerminalNo) +
          ') And (ShiftNo = ' + IntToStr(nShiftNo) + ')' );
        Open;
        if NOT EOF then
          nCurDwrAmount := Fields[0].AsCurrency;
        Close;SQL.Clear;
        SQL.Add('SELECT Sum(M.DlySales) from MedShift M ' +
          'where (M.MediaNo = 1) And (TerminalNo = ' + IntToStr(ThisTerminalNo) +
          ') And (ShiftNo = ' + IntToStr(nShiftNo) + ')' );
        Open;
        if NOT EOF then
          nCurDwrAmount := nCurDwrAmount + Fields[0].AsCurrency;
        If (nCurDwrAmount < nAmount) then
          bOverLimit := True;
        Close;
      end;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end
  else if (BankHALO > 0) and (nAmount > BankHALO) then
  begin
    bOverLimit := True;
  end;

  if bOverLimit then
  begin
    POSError('Over High Amount Limit');
    Exit;
  end;

  if SaleState = ssNoSale then
    AssignTransNo;


  if BankRecType <> 2 then  {1 = paid out 2 = income 3 = cash drop}
    nAmount := nAmount * -1;

  SaleState := ssBankFunc;
  sLineType := 'BNK';
  sSaleType := 'Sale';

  AddSaleList;


  ComputeSaleTotal;
  ClearEntryField;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.AddTaxList
  Author:    Glen Martin
  Date:      17-Aug-2006
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.AddTaxList();
var
  t,i, FirstTax : Integer;
  outer, inner, FirstMed : Integer;
  ST : pSalesTax;
  SD : pSalesData;
  CurSaleData : pSalesData;
begin
  outer := 0;
  FirstMed := -1;
  while outer <= Pred( CurSaleList.Count ) do        //Remove current TAX lines, if any from Current Sales List
  begin
    SD := pSalesData( CurSaleList.Items[ outer ] );
    if SD.LineType = 'TAX' then
    begin
      try
        Dispose( SD );
      except
         on E: Exception do
         begin
           UpdateExceptLog( 'Exception %s( %s ) while Disposing of a TAX line (%d)', [ E.ClassName, E.Message, integer(CurSaleList.Items[ outer ]) ]);
         end;
      end;
      CurSaleList.Delete( outer );
      if outer <= Pred( CurSaleList.Count ) then
        for inner := outer to Pred( CurSaleList.Count ) do
          dec( pSalesData( CurSaleList.Items[ inner ] ).SeqNumber );
    end
    else
    begin
      if ( FirstMed = -1 ) and ( pSalesData( CurSaleList.Items[ outer ] ).LineType = 'MED' ) then
        FirstMed := outer;
      inc( outer );
    end;
  end;
  if FirstMed = -1 then
    FirstMed := outer;

  FirstTax := FirstMed + 1;
  i := FirstTax;
  for t := 0 to Pred( CurSalesTaxList.Count ) do
  begin
    ST := CurSalesTaxList.Items[t];
    if ST^.Taxable <> 0 then
    begin
      New( CurSaleData );
      ZeroMemory( CurSaleData, sizeof( TSalesData ) );
      CurSaleData^.SeqNumber   := i;
      CurSaleData^.LineType    := 'TAX';    {DPT, PLU, MED}
      CurSaleData^.SaleType    := '';       {Sale, Void, Rtrn, VdVd, VdRt}
      CurSaleData^.LineVoided  := False;
      CurSaleData^.Number      := 0;
      CurSaleData^.Name        := ST^.TaxName ;
      CurSaleData^.Qty         := 0;
      CurSaleData^.Price       := 0;
      CurSaleData^.ExtPrice    := ST^.TaxCharged;
      CurSaleData^.mediarestrictioncode := MRC_SALESTAX;
      CurSaleData^.GiftCardRestrictionCode := RC_NO_RESTRICTION;
      CurSaleData^.LineID := GetLineID();

      CurSaleList.Capacity := CurSaleList.Count;
      CurSaleList.Insert(i-1,CurSaleData);

      inc(i);
    end;
  end;
  if i <> FirstTax then
    for t := 0 to CurSaleList.Count-1 do
    begin
      CurSaleData := CurSaleList.Items[t];
      if curSaleData^.LineType = 'MED' then
        curSaleData^.SeqNumber := curSaleData^.SeqNumber + (i - FirstTax);
    end;
end;

procedure ExtractVCIFromSalesList(const qSalesData : pSalesData; const pVCI : pValidCardInfo);
begin
  pVCI.cardsource        := csSalesList;
  pVCI.Track1Data        := '';
  pVCI.Track2Data        := '';
  pVCI.CardError         := '';
  pVCI.CardType          := qSalesData^.CCCardType;
  pVCI.CardTypeName      := '';
  pVCI.iFaceValueCents   := 0;
  pVCI.bActivationType   := False;
  pVCI.bGetDriverID      := False;
  pVCI.bGetOdometer      := False;
  pVCI.bGetRefNo         := False;
  pVCI.bGetVehicleNo     := False;
  pVCI.bGetZIPCode       := False;
  pVCI.bAskDebit         := False;
  pVCI.bDebitBINMngt     := False;
  pVCI.bValid            := True;
  pVCI.CardNo            := qSalesData^.CCCardNo;
  pVCI.ExpDate           := qSalesData^.CCExpDate;
  pVCI.ServiceCode       := '';
  pVCI.CardName          := qSalesData^.CCCardName;
  pVCI.VehicleNo         := qSalesData^.CCVehicleNo;
  pVCI.AuthID            := qSalesData^.CCAuthId;
  pVCI.FinalAmount       := qSalesData^.ExtPrice;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.AddMediaList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
function TfmPOS.AddMediaList(const Med : pDBMediaRec) : pSalesData;
var
  j : integer;
  CurSaleData : pSalesData;
  sd : pSalesData;
  pi : pPaymentInfo;
  authamountleft, apply : currency;
  cpfl : TNotList;
begin
  New(CurSaleData);
  ZeroMemory(CurSaleData, sizeof(TSalesData));
  CurSaleData^.SeqNumber   := CurSaleList.Count + 1;
  CurSaleData^.LineType    := 'MED';    {DPT, PLU, MED}
  CurSaleData^.SaleType    := '';       {Sale, Void, Rtrn, VdVd, VdRt}  //WTF are we blanking it out
  CurSaleData^.LineVoided  := False;
  CurSaleData^.Number      := Med.MediaNo;
  CurSaleData^.Name        := Med.Name ;
  CurSaleData^.Qty         := 0;
  CurSaleData^.Price       := 0;
  CurSaleData^.ExtPrice    := nAmount;
  CurSaleData^.AutoDisc := False;

  CurSaleData^.TaxNo   := 0;   // Init Tax Stuff
  CurSaleData^.TaxRate := 0;
  CurSaleData^.Taxable := 0;

  CurSaleData^.WEXCode := 0;
  CurSaleData^.PHHCode := 0;
  CurSaleData^.IAESCode := 0;
  CurSaleData^.VoyagerCode := 0;

  CurSaleData^.SavDiscable := 0;
  CurSaleData^.SavDiscAmount := 0;

  CurSaleData^.LineID := GetLineID();

  CurSaleData^.PLUModifier := Med.RECTYPE;
  if Med.RECTYPE in [CREDIT_MEDIA_TYPE, DEBIT_MEDIA_TYPE, FOOD_STAMP_MEDIA_TYPE, DEFAULT_GIFT_CARD_MEDIA_TYPE, EBT_FS_MEDIA_TYPE ] then
  begin
    moveCRDintoSaleData(@rCRD, CurSaleData);
    CurSaleData^.Name := GetCardTypeNameByCardType(trimright(CurSaleData^.CCCardType));
  end
  else if Med.RECTYPE in [COUPON_MEDIA_TYPE, CASH_MEDIA_TYPE, CHECK_MEDIA_TYPE] then
  begin
    authamountleft := nAmount;
    cpfl := CanPayFor( Med.mediarestrictioncode, CurSaleList );
    for j := 0 to pred( cpfl.Count ) do
    begin
      sd := pSalesData( cpfl[j] );
      if not assigned( sd.paidlist ) then
      {$IFDEF DEBUG}
      begin
      {$ENDIF}
        sd.paidlist := TNotList.Create;
        sd.paidlist.Name := format(' paidlist for %03d', [ sd^.SeqNumber ] );
      {$IFDEF DEBUG}
        UpdateZLog('Created paidlist for %03d %-20.20s', [ sd^.SeqNumber, sd^.Name ]);
      end;
      {$ENDIF}
      new(pi);
      pi.LineID := CurSaleData^.LineID;
      pi.AuthID := -1;
      apply := min(authamountleft, sd^.extprice);
      pi.Amount := apply;
      authamountleft := authamountleft - apply;
      sd.paidlist.Add(pi);
      if authamountleft <= 0 then break;
    end;
  end;

  //...bp
  CurSaleData^.ActivationState := asActivationDoesNotApply;
  CurSaleData^.ActivationTransNo := 0;
  CurSaleData^.ActivationTimeout := 0;
  CurSaleData^.ccPIN := '';
  CurSaleData^.MODocNo := '';
  CurSaleData^.PriceOverridden := False;
  CurSaleList.Capacity := CurSaleList.Count;
  j := CurSaleList.Add(CurSaleData);

  UpdateZLog('AddMediaList - Added %s for %.2f in position %d', [CurSaleData^.Name, CurSaleData^.ExtPrice, j]);

  DisplayMedia(CurSaleData);
  Result := CurSaleData;
end;  // procedure TfmPOS.AddMediaList

procedure TfmPOS.moveCRDintoSaleData(pCRD: pCreditResponseData; CurSaleData : pSalesData);
var
  j : integer;
  sd : pSalesData;
  pi : pPaymentInfo;
  authamountleft, apply : currency;
begin
  with pCRD^ do
  begin
    CurSaleData^.CCAuthCode     := sCCAuthCode;
    CurSaleData^.CCApprovalCode := sCCApprovalCode;
    CurSaleData^.CCDate         := sCCDate;
    CurSaleData^.CCTime         := sCCTime;
    CurSaleData^.CCCardNo       := sCCCardNo;
    CurSaleData^.CCCardType     := sCCCardType;
    CurSaleData^.CCCardName     := sCCCardName;
    CurSaleData^.CCExpDate      := sCCExpDate;
    CurSaleData^.CCBatchNo      := sCCBatchNo;
    CurSaleData^.CCSeqNo        := sCCSeqNo;
    CurSaleData^.CCEntryType    := sCCEntryType;
    CurSaleData^.CCVehicleNo    := sCCVehicleNO;
    CurSaleData^.CCOdometer     := sCCOdometer;
    CurSaleData^.CCCPSData      := sCCCPSData;
    CurSaleData^.CCRetrievalRef := sCCRetrievalRef;
    CurSaleData^.CCAuthNetId    := sCCAuthNetID;
    CurSaleData^.CCAuthorizer   := sCCAuthorizer;
    CurSaleData^.CCTraceAuditNo := sCCTraceAuditNo;
    CurSaleData^.GiftCardRestrictionCode := iCCGiftRestriction;
    for j := low(CurSaleData^.CCPrintLine) to high(CurSaleData^.CCPrintLine) do
      CurSaleData^.CCPrintLine[j]  := sCCPrintLine[j];
    CurSaleData^.CCBalance1    := nCCBalance1;
    CurSaleData^.CCBalance2    := nCCBalance2;
    CurSaleData^.CCBalance3    := nCCBalance3;
    CurSaleData^.CCBalance4    := nCCBalance4;
    CurSaleData^.CCBalance5    := nCCBalance5;
    CurSaleData^.CCBalance6    := nCCBalance6;
    CurSaleData^.CCRequestType := nCCRequestType;
    CurSaleData^.CCAuthID      := nCCAuthID;
    CurSaleData^.mediarestrictioncode := mediarestrictioncode;
    authamountleft             := nChargeAmount;
    if sEMVauthCFM <> '' then
    begin
      CurSaleData^.emvauthconf := PurgeSADTags(sEMVauthCFM);
    end
    else
    if sEMVresp <> '' then
    begin
       CurSaleData^.emvauthconf := PurgeSADTags(sEMVresp);
    end;
  end;
  if assigned( pCRD^.Paiditems ) then
  begin
    for j := 0 to pred( pCRD^.PaidItems.Count ) do
    begin
      sd := pSalesData( pCRD^.PaidItems[j] );
      if not assigned( sd.paidlist ) then
      begin
        sd.paidlist := TNotList.Create;
        sd.paidlist.name := format(' paidlist for %03d', [ sd^.SeqNumber ] );
      end;
      new(pi);
      pi.AuthID := pCRD^.nCCAuthID;
      pi.LineID := -1;
      apply := min(authamountleft, sd^.extprice);
      pi.Amount := apply;
      authamountleft := authamountleft - apply;
      sd.paidlist.Add(pi);
    end;
  end
  else
     UpdateZLog('There were no paid items :local');
end;

procedure TfmPOS.DisplayMedia(const qSalesData : pSalesData; const qOriginalSalesData : pSalesData = nil);
const
  FS_CHANGE_TEXT = 'Food Stamp Change';
var
  s : string;
  j : integer;
  IndexMediaLine : integer;
  InitialMediaLineText : string;
  IndexFSChange : integer;
  bAddAtEnd : boolean;
  function FormatMediaLine(const sd : pSalesData) : string;
  begin
    FormatMediaLine := Format('%23s',[sd^.Name]) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-', sd^.ExtPrice))]);
  end;
begin
  // If exists, then locate food stamp change line
  IndexFSChange := -1;
  for j := POSListBox.Count - 1 downto 0 do
  begin
    if (POS(FS_CHANGE_TEXT, POSListBox.Items.Strings[j]) > 0) then
    begin
      IndexFSChange := j;
      break;
    end;
  end;
  // If not modifying an existing line then new entry will be added to end; otherwise, locate the existing line.
  bAddAtEnd := True;  // Initial assumption (could be changed below if insert becomes necessary).
  if (qOriginalSalesData = nil) then
  begin
    IndexMediaLine := POSListBox.Count - 1;
  end
  else
  begin
    InitialMediaLineText := FormatMediaLine(qOriginalSalesData);
    IndexMediaLine := -1;
    for j := POSListBox.Count - 1 downto 0 do
    begin
      if (POS(InitialMediaLineText, POSListBox.Items.Strings[j]) > 0) then
      begin
        IndexMediaLine := j;
        UpdateZLog('DisplayMedia - Modifying Line: "%s"', [InitialMediaLineText]);
        bAddAtEnd := (IndexMediaLine = POSListBox.Count - 1);
        POSListBox.Items.Delete(IndexMediaLine);
        break;
      end;
    end;
  end;
  // Add or insert media line.
  s := FormatMediaLine(qSalesData);
  if (bAddAtEnd) then
  begin
    POSListBox.AddLast(s);
    UpdateZLog('DisplayMedia - Adding Line: "%s"', [s]);
  end
  else
  begin
    POSListBox.Insert(IndexMediaLine, s);
    UpdateZLog('DisplayMedia - Inserting Line: "%s" at index %d', [s, IndexMediaLine]);
  end;

  if (Round(qSalesData^.Number) = FOOD_STAMP_MEDIA_NUMBER) then
  begin
    // If food stamp change applies,...
    if ((curSale.nFSChange <> 0) or (IndexFSChange >= 0)) then
      begin
        s := Format('%23s',[FS_CHANGE_TEXT]) + ' ' + Format('%11s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nFSChange))]);
        bAddAtEnd := ((IndexFSChange < 0) or (IndexFSChange = POSListBox.Count - 1));
        if (IndexFSChange >= 0) then
          POSListBox.Items.Delete(IndexFSChange);
        if (bAddAtEnd) then
          POSListBox.AddLast(s)
        else
          POSListBox.Insert(IndexFSChange, s);
      end;
    end;

  POSListBox.Refresh;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ClearEntryField
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ClearEntryField();
begin
  {$IFDEF PLU_MOD_DEPT}
  if (sKeyType <> 'COP') then  //20061023b
    sKeyVal := '';  //20060713f
  {$ENDIF}
  sEntry := '';
  nNumber := 0;
  nAmount := 0;
  nExtAmount := 0;
  DisplayEntry.Text := '';

  DisplayQty.Visible := False;
  DisplayQty.Text := '';
  nQty := 0;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.AssignTransNo
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.AssignTransNo();
var
  RepeatCount : short;
  OldTransNo, NewTransNo : integer;
begin
  oldTransNo := curSale.nTransNo;
  RepeatCount := 0;
  while oldTransNo = curSale.nTransNo do
  begin
    inc(RepeatCount);
    if POSDataMod.IBSpTransNo.Transaction.InTransaction then
      UpdateExceptLog('IBShiftTransaction already started')
    else
      POSDataMod.IBSpTransNo.Transaction.StartTransaction;
    try
      POSDataMod.IBSpTransNo.Close;
      if not POSDataMod.IBSpTransNo.Prepared then
        POSDataMod.IBSpTransNo.Prepare;
      POSDataMod.IBSpTransNo.ExecProc;
      NewTransNo := POSDataMod.IBSpTransNo.ParamByName('TransNo').AsInteger;
      POSDataMod.IBSpTransNo.Transaction.Commit;
      curSale.nTransNo := NewTransNo;
    except
      on E: Exception do
      begin
        POSDataMod.IBSpTransNo.Transaction.Rollback;
        if pos('lock conflict on no wait transaction', E.Message) = 0 then
          raise;
      end;
    end;
  end;
  if RepeatCount > 1 then
    UpdateExceptLog('Took %d tries to get a new transaction number', [RepeatCount]);

  StatusBar1.Panels.Items[1].Text := 'Trans# ' + Format('%6d',[curSale.nTransNo]);
  if not POSDataMod.IBShiftTransaction.InTransaction then
      POSDataMod.IBShiftTransaction.StartTransaction;
  with POSDataMod.IBShiftQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select CurShift From Terminal Where TerminalNo = ' + IntToStr(ThisTerminalNo));
    Open;
    nShiftNo := FieldByName('CurShift').AsInteger;
    Close;
    if POSDataMod.IBShiftTransaction.InTransaction then
      POSDataMod.IBShiftTransaction.Commit;
  end;
  StatusBar1.Panels.Items[0].Text := 'Terminal# ' + IntToStr(ThisTerminalNo) + ' Shift# ' + InttoStr (nShiftNo);
  if SaleState = ssNoSale then
    qClient^.bCreditAuthFailed := False;

  UpdateZLog('TfmPOS.AssignTransNo - %d', [curSale.nTransNo]);
  // Pin pad class needs to know when transaction changes so it can re-initiate credit prompting.
  if (PPTrans <> nil) then
    PPTrans.TransNo := curSale.nTransNo;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.SalesComplete
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    Boolean
  Purpose:
-----------------------------------------------------------------------------}
function TfmPOS.SalesComplete : Boolean;
var
  i            : Integer;
  Pumpid_found : Boolean;
  //Mega Suspend
  Ret : Boolean;
  //Mega Suspend
begin
  Pumpid_found := False;
  if bFuelSystem and (ThisTerminalNo = MasterTerminalNo) then
  begin
    For i:= 1 to NO_PUMPS do
    If (nPumpIcons[i].Sale1ID > 0) or (nPumpIcons[i].Sale2ID > 0 )
                                   or (nPumpIcons[i].Sale1Status > 0 ) Then
      Pumpid_found := True;
  end;

  if (SaleState <> ssNoSale)     //     or (StackListBox.Items.Count > 0)
      or (bSuspendedSale = True) or Pumpid_found then
    //Mega Suspend
    Ret := false
    //SalesComplete := False
  else
    Ret := true;
    //SalesComplete := True;
  if not POSDataMod.IBSuspendTrans.InTransaction then
    POSDataMod.IBSuspendTrans.StartTransaction;
  with POSDataMod.IBSuspendQry do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from SuspendSale');
    Open;
    if RecordCount > 0 then
      Ret := False;
    Close;
  end;
  if POSDataMod.IBSuspendTrans.InTransaction then
    POSDataMod.IBSuspendTrans.Commit;
  SalesComplete := Ret;
  //Mega Suspend
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FormClose
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; var Action: TCloseAction
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.FormClose(Sender: TObject; var Action: TCloseAction);
var
  i            : Integer;
  CloseAnyway  : Boolean;
begin
  if NOT bPOSForceClose then
  begin
    if not SalesComplete then
    Begin
      CloseAnyWay := False;
      If fmPOSErrorMsg.Continue('POS Confirm', 'Closing not possible ! Finish sales first') = mrYes Then
        CloseAnyWay := True;
      if Not CloseAnyWay then
      begin
        Action    := caNone;
        Exit;
      end;
    End;
  end;

  SyncLogs := True;
  UpdateZLog(''); // Flushing logs

  try
    PumpLockMgr.Free;
  except
    on E: Exception do
    begin
      UpdateExceptLog('Exception %s thrown freeing PumpLockMgr - %s', [E.ClassName, E.Message]);
      DumpTraceBack(E);
    end;
  end;

  try
    FFPCPostThread.Terminate;
  except
  end;
  try
    FFPCPostThread.Destroy;
  except
  end;
  FFPCPostThread := nil;

  bClosingPOS := True;
  //20070905d...
  if bPOSForceClose then
    LogMemo('CLS', '                   ***** POS Shutdown - Forced *****')
  else
    LogMemo('CLS', '                   ***** POS Shutdown - Normal *****');
  //...20070905d

  try

    fmPOSErrorMsg.Visible := False;
    fmPOSMsg.Visible := False;
    fmFuelSelect.Visible := False;
    fmPLUSalesReport.Visible := False;
    fmValidAge.Visible := False;
    fmEnterAge.Visible := False;
    //fmADSCCForm.Visible := False;
    fmNBSCCForm.Visible := False;
    fmCardReceipt.Visible := False;
    fmFuelReceipt.Visible := False;
    fmPopUpMsg.Visible := False;
    //Build 19
    fmPriceOverride.visible := false;
    fmPriceCheck.visible := false;
    //Build 19
    fmUser.Visible := False;
    if NOT bPOSForceClose then
      fmPOSMsg.ShowMsg('Closing POS', '');

    Timer1.Enabled := False;
    PopUpMsgTimer.Enabled := False;

    ClosePole;

    if NOT bPOSForceClose then
      fmPOSMsg.ShowMsg('Closing Credit', '');

    try
      if (CreditHostReal(nCreditAuthType)) then
      begin
        Credit.Terminate;
        Credit := nil;
      end;

    except
    end;

    //cwa...
    case Setup.CarWashInterfaceType of
    CWSRV_UNITEC, CWSRV_PDQ :
      begin
        if (DCOMCarWash <> nil) then
          begin

            DCOMCarWash := nil;
          end;
      end;
    end;
    //...cwa

    try
    if bFuelSystem then
      begin
        if NOT bPOSForceClose then
          fmPOSMsg.ShowMsg('Closing Fuel', '');

        case nFuelInterfaceType of
        1,2 :
          begin
            if not (Fuel = nil) then
              begin
                //Fuel.DisConnectPOSClient(ThisTerminalUNCName, ThisTerminalNo);
                //DCOMFuelProg := nil;
              end;
          end;
        end;

      end;
    except
    end;

    try
    if Setup.MOSystem then
      begin
        if NOT bPOSForceClose then
          fmPOSMsg.ShowMsg('Closing Money Orders', '');
        MO.Terminate;
        FreeAndNil(MO);
        FreeAndNil(MOTCPClient);
      end;
    except
    end;

    fmPOSMsg.ShowMsg('Cleaning Up', '');
    Config.Destroy;

    CloseTables;
    ClosePorts;

    Receiptlist.Free;

    DeleteCriticalSection(CSSuspendList);

    //20050217
    FSList.Free;
    CCList.Free;
    MOList.Free;
    //20050217

    For i:= 1 to No_Pumps do
      begin
        try
          nPumpIcons[i].Free;
        except
        end;
      end;

    FreePumpFrames;
      
    fmPOSMsg.Close;
   PostMessage(POSMenu.Handle,WM_CLOSEPOS,0,0);
  finally
    try
      Application.Terminate;
    except
      on E: Exception do
        UpdateExceptLog('Failed to terminate application %s - %s', [E.ClassName, E.Message]);
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ClosePorts
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ClosePorts;
var
  i : integer;
begin
  case bCashDrawerActive of
  1 :
    begin
    end;
  2 :
    begin
      (*OPOSCashDrawer.DeviceEnabled := False;
      OPOSCashDrawer.Release;
      OPOSCashDrawer.Close;*)
    end;
  end;

  case bPoleActive of
  1 :
    begin
      if PolePort <> nil then
      begin
      PolePort.Open := False;
        FreeAndNil(FPolePort);
    end;
    end;
  2 :
    begin
      OPOSPoleDisplay.DeviceEnabled := False;
      OPOSPoleDisplay.ReleaseDevice;
      OPOSPoleDisplay.Close;
    end;
  end;

  case bMSRActive of
  1 :
    begin
      if assigned(MSRPort) then
      begin
        MSRPort.Open := False;
        FreeAndNil(MSRPort);
      end;
    end;
  2 :
    begin
      if CheckNCRMSR(MSROPOSName) then
      begin
        OPOSMSR.DeviceEnabled := False;
        OPOSMSR.ReleaseDevice;
        OPOSMSR.Close;
      end;
    end;
  end;

  if length(scannerports) > 0 then
  begin
    for i := 0 to pred(length(scannerports)) do
    begin
      ScannerPorts[i].Open := False;
      ScannerPorts[i].Free;
      ScannerPorts[i] := nil;
      ScannerComPorts[i] := 0;
    end;
    setlength(scannerports, 0);
    setlength(scannercomports, 0);
  end;

  case bScannerActive of
  2 :
    begin
      OPOSScanner.DeviceEnabled := False;
      OPOSScanner.ReleaseDevice;
      OPOSScanner.Close;
    end;
  end;

  if (PPTrans <> nil) then
  try
    PPTrans.PINPadClose();
    PPTrans.Free;
    PPTrans := nil;
  except
    on E: Exception do UpdateExceptLog('TfmPOS.ClosePorts: Problem executing PPTrans.PINPadClose - %s - %s', [E.ClassName, E.Message]);
  end;

  if bPriceSignActive > 0 then
  begin
    PriceSignPort.Open := False;
    FreeAndNil(FPriceSignPort);
  end;

  if KybdPort <> nil then
  begin
  KybdPort.Open := False;
    FreeAndNil(KybdPort);
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.Timer1Timer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.Timer1Timer(Sender: TObject);
Var
  Salefound     : Boolean;
  Callfound     : Boolean;
  DriveOffFound : Boolean;
  MyPump    : TPumpxIcon;
  i         : Integer;
  DummyCCMsg : string;
  CurrentTime : TDateTime;
  qSalesData : pSalesData;

begin
  try
    if bClosingPOS or bPOSForceClose or (fmPOS = nil) then
      exit;
  //20071018b...
  if not (fmPOS.Handle = GetActiveWindow) then
    exit;
  //...20071018b
  try
    if (CurSaleList.Count = 0) and (nTimercount = 100) Then
    begin
      If (bPoleActive > 0)  and bScrollMessActive then
      Begin
        bScrollMessOn := True;
        nScrollPtr := 21;
        sScrollBuff :=  #16#19#32#16#0 + copy(sScrollMess,1,20);
      End;
      BlankPole;
    end;

    if (CurSaleList.Count > 0) AND NOT(PRINT_OLD_RECEIPT) then
      bScrollMessOn := False;

    if bScrollMessOn and (bPoleActive > 0) then
    begin
      ScrollPole(sScrollBuff);
      sScrollBuff := copy(sScrollBuff,1,5) + copy(sScrollBuff,7,19) + sScrollMess[nScrollPtr];
      if nScrollPtr = nScrollSize then
        nScrollPtr := 1
      else
        Inc(nScrollPtr,1);
    end;
  except
  end;


  try
    StatusBar1.Panels.Items[3].Text := FormatDateTime('h:mm AM/PM',Time);
  except
    UpdateExceptLog('Error Updateing Status Panel');
  end;
  if (bPoleActive > 0) then
  try
    Inc(nTimercount);
    If (nTimercount = 18) and   { 2 Seconds since last key...we show a subtotal }
       (SaleState = ssSale) Then
    Begin
      UpdateZLog('Calling ReComputeSaleTotal from timer');
      ReComputeSaleTotal(False);
      If curSale.nTotal <> 0 Then
      Begin
        AssignPoleString('SUBTOTAL   ' +  Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',curSale.nTotal))]));
        PrintPole;
      End;
    End
    Else If (nTimercount = 18) and   { 2 Seconds since last key...we show a subtotal }
       (SaleState = ssTender) Then
    Begin
 //       ComputeSaleTotal;
      If curSale.nTotal <> 0 Then
      Begin
        AssignPoleString('TOTAL      ' +  Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',curSale.nTotal))]) +
                         'AMOUNT DUE ' +  Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',curSale.nAmountDue))])  );
        PrintPole;
      End;
    End;
    If nTimercount > 10000 Then
      nTimercount := 0;
  except
  end;


  try
    Callfound := False;
    Salefound := False;
    DriveOffFound := False;
    For i := 1 to NO_PUMPS do
    Begin
      MyPump := nPumpIcons[i];
      If MyPump <> Nil Then
      Begin
        If MyPump.Sound = SOUND_CALL Then
          Callfound := True;
        If MyPump.Sound = SOUND_COLLECT Then
          Salefound := True;
        If MyPump.Sound = SOUND_DRIVEOFF Then
          DriveOfffound := True;
      End;
    End;

    If CallFound Then        { Callfound has priority... }
    begin
      DriveOfffound := False;
      Salefound     := False;
    end;

    If DriveOffFound then
    begin
      CallFound := False;
      SaleFound := False;
    end;

    if CurrentUserID = '' then
    begin
      CallFound := False;
      DriveOffFound := False;
    end;

    If (Callfound and ((Call_Beeper mod 8) = 0)) or
       ((Salefound or DriveOffFound) and ((Call_Beeper mod 120) = 0)) Then
    Begin
      if bPlayWave then
      begin
        If DriveOffFound Then
        Begin
          (*{$ifdef TOC}
          PlaySound( 'DRIVEOFF', HInstance, SND_ASYNC or SND_RESOURCE) ;
          {$else}
          PlaySound( 'DRIVEOFF711', HInstance, SND_ASYNC or SND_RESOURCE) ;
          {$endif}*)
          if fmPOS.bPlayWave then MakeNoise( DRIVEOFFSOUND) ;
        End
        Else If Salefound Then
        Begin
          PlaySound( 'COLLECT', HInstance, SND_ASYNC or SND_RESOURCE) ;
        End
        Else If Callfound Then
        Begin
          PlaySound( 'PUMPCALL', HInstance, SND_ASYNC or SND_RESOURCE) ;
        End;
      end
      else
      begin
        If (Callfound or Salefound or DriveOffFound) Then
          MessageBeep(1);
      end;
    end;
  except
  end;


  try
    Inc (Call_Beeper);
    If Call_Beeper > 10000 Then
      Call_Beeper := 0;
  except
  end;

  try
    if POSDate <> Date then
    begin
      POSDate := Date;
      StatusBar1.Panels.Items[2].Text := FormatDateTime('dddd, mmm d,yyyy',POSDate);
    end;
  except
  end;

  try
    //if (Time > 0.083) and (Time < 0.085) and not (bBackupDone) then  // Fire the backup around 2:00am
    if (Time > Setup.BackupTime) and (Time < (Setup.BackupTime + 0.002)) and not (bBackupDone) then  // Fire the backup around 2:00am
    begin
      bBackUpDone := True;
      PostMessage(fmPOS.Handle, WM_BACKUP, 0, 0);
    end;
  except
  end;

  // Check for any timeouts (from credit server responses) for product activations:
  if (CurSaleList.Count > 0) then
  begin
    CurrentTime := Now();
    if (FCardActivationTimeout > 0) and (FCardActivationTimeout < CurrentTime) then
    begin
      for i := 0 to CurSaleList.Count - 1 do
      begin
        qSalesData := CurSaleList.Items[i];
        if (qSalesData^.ActivationState in [asWaitBalance, asActivationNeeded, asActivationPending]) then
        begin
          // Fail Safe:  Give up waiting on credit server (normally credit server will send timeout).
          // Generate a dummy "deny response" similar to what the credit server would have sent.
          DummyCCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_AUTHRESP_ACT))
                      + BuildTag(TAG_CHARGEALLOWED, '0')
                      + BuildTag(TAG_AUTHCODE, '89')
                      + BuildTag(TAG_AUTHRESPMSG, 'No Crdt Srvr Resp')
                      + BuildTag(TAG_TRANSNO, IntToStr(qSalesData^.ActivationTransNo))
                      + BuildTag(TAG_USERDATACOUNT, IntToStr(qSalesData^.LineID) );
          New(StatusMsg);
          StatusMsg.Text := DummyCCMsg;
          PostMessage(fmPOS.Handle, WM_ACTIVATION, 0, LongInt(StatusMsg));
          UpdateExceptLog('Activation timeout for ' + qSalesData^.Name + ' - Dummy Msg generated: ' + DummyCCMsg);
        end;
      end;
      FCardActivationTimeout := 0;
    end;
  end;
  except on E : Exception do
    begin
      UpdateExceptLog('TfmPOS.Timer1Timer - Exception "%s"', [E.Message]);
      DumpTraceback(E);
    end;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.SuspendSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.SuspendSale;
begin
  EnterCriticalSection(CSSuspendList);
  try
    SuspendList := TList.Create;
    SuspendList.Assign(CurSaleList);
  finally
    LeaveCriticalSection(CSSuspendList);
  end;

  CurSaleList.Clear;

  nSavFSSubtotal  := curSale.nFSSubtotal;
  nSavSubtotal    := curSale.nSubtotal;
  nSavTlTax       := curSale.nTlTax;
  nSavTotal       := curSale.nTotal;
  //Gift
  nSavMedia       := curSale.nMedia;
  //Gift
  nSavCustBDay    := nCustBDay;
  nSavBeforeDate  := nBeforeDate;

  nSavNonTaxable  := curSale.nNonTaxable;
  nSavDiscable    := curSale.nDiscountableTl;

  curSale.nFuelSubtotal := 0;
  curSale.nFSSubtotal     := 0;
  curSale.nSubtotal       := 0;
  curSale.nTlTax          := 0;
  curSale.nTotal          := 0;
  nCustBDay       := 0;
  fmPOS.nCustBDayLog := 0;  // Clear Birthday for logging                       //20070926a
  nBeforeDate     := 0;
  curSale.nNonTaxable     := 0;
  curSale.nDiscountableTl := 0;

  bSuspendedSale := True;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.RecallSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.RecallSale;
var
  ndx: byte;
  SD : pSalesData;
begin

  CurSaleList.Clear;
  EnterCriticalSection(CSSuspendList);
  try
    CurSaleList.Assign(SuspendList);
    SuspendList.Clear();
    for ndx := 0 to (CurSaleList.Count - 1) do
      begin
        SD := CurSaleList.Items[ndx];
        if SD^.LineType <> 'TAX' then
        begin
          {$IFDEF FUEL_PRICE_ROLLBACK}
          DisplaySaleList(SD, False);
          {$ELSE}
          DisplaySaleList(SD);
          {$ENDIF}
        end;
      end;
    ComputeSaleTotal;

    SuspendList.Clear;
    SuspendList.Free;
    SuspendList := nil;
  finally
    LeaveCriticalSection(CSSuspendList);
  end;
  curSale.nFSSubtotal := nSavFSSubtotal;
  curSale.nSubtotal := nSavSubtotal;
  curSale.nTlTax := nSavTlTax;
  curSale.nTotal := nSavTotal;
  //Gift
  curSale.nMedia := nSavMedia;
  curSale.nAmountDue := curSale.nTotal - curSale.nMedia;
  //Gift
  nCustBDay := nSavCustBDay;
  fmPOS.nCustBDayLog := nSavCustBDay;  //Recover Birthday for logging           //20070926a
  nBeforeDate := nSavBeforeDate;
  curSale.nNonTaxable := nSavNonTaxable;
  curSale.nDiscountableTl := nSavDiscable;

  nSavFSSubtotal := 0;
  nSavSubtotal := 0;
  nSavTlTax := 0;
  nSavTotal := 0;
  //Gift
  nSavMedia := 0;
  //Gift
  nSavCustBDay := 0;
  nSavBeforeDate := 0;
  nSavNonTaxable := 0;
  nSavDiscable   := 0;

  bSuspendedSale := False;
  //Gift
  // Restore previous logical credit client.
  qClient := qSuspendedClient;
  //Gift
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.RestrictionCodeOK
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RestrictionCode : integer
  Result:    Boolean
  Purpose:
-----------------------------------------------------------------------------}
function TfmPOS.RestrictionCodeOK(RestrictionCode : integer): Boolean;
var
  RetVal : boolean;
  StartStr, StopStr : string;
  nAgeRestriction : integer;
  nStartTime, nStopTime, CurrTime : TDateTime;
  AgeModalResult : TModalResult;
  ProdRestrictionCode : integer;
begin

  RetVal := True;
  //Gift
  ProdRestrictionCode := RestrictionCode mod MAX_NUM_RESTRICTION_CODES;  // Strip off "giftcard" portion.
  if ((RestrictionCode <= 0) or (ProdRestrictionCode = 0)) then
    begin
      RestrictionCodeOK := RetVal;
      exit;                         // No restrictions.
    end;
  //Gift
  nAgeRestriction := 0;
  nStartTime      := 0;
  nStopTime       := 0;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBRestrictionQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from Restriction where RestrictionCode = :pRestrictionCode');
    ParamByName('pRestrictionCode').AsInteger :=
    //Gift
    ProdRestrictionCode;
    //RestrictionCode;
    //Gift
    Open;
    if NOT EOF then
    begin
      nAgeRestriction := FieldByName('Age').AsInteger;
      StartStr   := 'StartDay' + IntToStr(DayOfWeek(Date));
      StopStr    := 'StopDay' + IntToStr(DayOfWeek(Date));
      nStartTime := FieldByName(StartStr).AsDateTime;
      nStopTime  := FieldByName(StopStr).AsDateTime;
    end;
    Close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  if (nAgeRestriction > 0) and not CustAgeOK(nAgeRestriction) then
  begin
    fmValidAge.Visible := False;
    fmValidAge.AgeRestriction := nAgeRestriction;
    fmEnterAge.AgeRestriction := nAgeRestriction;

    case nAgeValidationType of
      VAL_PROMPTDATE :
        begin
          if fmValidAge.ShowModal = mrCancel then
          begin
            ClearEntryField;
            RetVal := False;
          end;
        end;
      VAL_ENTERDATE  :
        begin
          if fmEnterAge.ShowModal = mrCancel then
          begin
            POSError('The Customer is NOT Old Enough to Purchase this Item');
            ClearEntryField;
            RetVal := False;
          end;
        end;
      VAL_DATEOPTION :
        begin

          AgeModalResult := fmValidAge.ShowModal ;
          if AgeModalResult = mrCancel then
          begin
            ClearEntryField;
            RetVal := False;
          end
          else if AgeModalResult = mrRetry then
          begin
            if fmEnterAge.ShowModal = mrCancel then
            begin
              POSError('The Customer is NOT Old Enough to Purchase this Item');
              ClearEntryField;
              RetVal := False;
            end;
          end;
        end;
      end;

      fmValidAge.ModalResult := mrOK;
      fmValidAge.Visible := False;
    end;

  if RetVal then
  begin
    if nStopTime > nStartTime then
    begin
      CurrTime := GetTime;
      if (CurrTime >= nStartTime) and (CurrTime <= nStopTime) then
      begin
        POSError('Time Restriction');
        RetVal := False;
      end;
    end;
  end;

  //20061207c...
  // Reset timer so that Pole Display shows Subtotal
  nTimerCount := 0;
  //...20061207c

  RestrictionCodeOK := RetVal;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CustAgeOK
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: AgeRestriction : integer
  Result:    Boolean
  Purpose:
-----------------------------------------------------------------------------}
function TfmPOS.CustAgeOK(AgeRestriction : integer): Boolean;
var
Year, Month, Day: Word;

begin
  DecodeDate(Date, Year, Month, Day);
  Year := Year - AgeRestriction;
  if (Month = 2) and (Day = 29) then
    Day := 28;
  nBeforeDate := EncodeDate(Year, Month,Day);
  nCustBDayLog := nCustBDay;
  if (nCustBDay <> 0) and (nCustBDay <= nBeforeDate) then
    CustAgeOK := True
  else
    CustAgeOK := False;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.POSError
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: ErrMsg: string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.POSError(ErrMsg: string; supplement : string);
begin
//20070910b
  // Log screen error message to the electronic journal.
  LogMemo('ERR', 'Error Message generated:  ' + ErrMsg + ' ' + supplement);
  if (not fmPOSErrorMsg.Active) then
  begin
    if assigned(Self.InjectionPort) and Self.InjectionPort.Open then
      Self.InjectionPort.PutString( #2 + 'ERR' + #30 + ErrMsg + #3 );
    //20070910b
  //  fmPOSErrorMsg.CapturePLU := False;
    try
      fmPOSErrorMsg.Continue('ERROR', errmsg, supplement);

      if not ((fmPOSErrorMsg.ModalResult = mrOK) or (fmPOSErrorMsg.ModalResult = mrYes)) then
        fmPOSErrorMsg.ModalResult := mrOK;

      fmPOSErrorMsg.Visible := False;
    except
      fmPOSErrorMsg.ModalResult := mrOK;
      sleep(100);
    end;  // try/except
  end;  // if (not fmPOSErrorMsg.Active)                                        //20070910b
  //20070307a...
  if ( not         fmPOSMsg.Visible) and
      (not     fmFuelSelect.Visible) and
      (not fmPLUSalesReport.Visible) and
      (not       fmValidAge.Visible) and
      (not       fmEnterAge.Visible) and
      (not      fmNBSCCForm.Visible) and
      (not   fmCWAccessForm.Visible) and
      (not    fmCardReceipt.Visible) and
      (not    fmFuelReceipt.Visible) and
      (not       fmPopUpMsg.Visible) and
      (not     fmPOSErrorMsg.Active) and                                       //20070910b
      (not           fmUser.Visible) then
  begin
    try  //20070509a
      fmPOS.DisplayEntry.SetFocus();
    except
    end;
  end;
  //...20070307a

end;

function TfmPOS.CreateTMGauge(tankno : integer) : TGauge;
begin
  Result := TGauge.Create(self);
  Result.Kind := gkVerticalBar;
  Result.BackColor := clWhite;
  Result.Width := 20;
  Result.ShowText := False;
  Result.Top := ETotal.Top;
  Result.Height := 100; //ETotal.Height;
  Result.Left := PPStatus.Left + PPStatus.Width + Result.Width*(tankno + 1);
  Result.Visible := True;
  Result.Enabled := True;
  Result.BringToFront;
  Result.Show;
  Result.Progress := 100;
  updateZLog('%d %dx%d @ %dx%d %d-%d', [tankno, result.width, result.height, result.left, result.Top, result.MinValue, result.MaxValue]);
end;

procedure TfmPOS.UpdateTMDisplay(const msg : string);
var
  i : integer;
  found : boolean;
  tname : string;
  tdiameter, theight : real;
  tg : TGauge;
begin
  if not assigned(self.FTMList) then
  begin
    self.FTMList := TList.Create();
    self.FTMList.Add(self.TMGauge1);
    self.FTMList.Add(self.TMGauge2);
    self.FTMList.Add(self.TMGauge3);
    self.FTMList.Add(self.TMGauge4);
    self.FTMList.Add(self.TMGauge5);
    for i := 0 to 4 do
      TGauge(self.FTMList[i]).Top := self.eTotal.Top;
  end;
  i := 0;
  found := True;
  UpdateZLog('p %dx%d @ %dx%d', [ppstatus.Width, ppstatus.height, ppstatus.left, ppstatus.Top]);
  while found do
  begin
    try
      tname := GetTagData(IntToStr(nFSTAG_TM_BASE + nTOFFSET*i + nFSTAG_TANK_NAME), msg, True);
      TDiameter := StrToFloat(GetTagData(IntToStr(nFSTAG_TM_BASE + nTOFFSET*i + nFSTAG_TM_DIAMETER), msg, True));
      THeight := StrToFloat(GetTagData(IntToStr(nFSTAG_TM_BASE + nTOFFSET*i + nFSTAG_TM_HEIGHT), msg, True));
      tg := TGauge(self.FTMList[i]);
      tg.Visible := True;
      tg.BringToFront;
        tg.Hint := tname;
        tg.Progress := trunc(THeight*100/TDiameter);
        UpdateZLog('TM %d %s %d', [i, tname, tg.Progress]);
        if tg.progress >= 50 then
          tg.foreColor := clLime
        else if tg.progress >= 10 then
          tg.foreColor := clYellow
        else
          tg.foreColor := clRed;
        tg.Refresh;
      inc(i);
    except
      on E: ETagMissing do
        found := False;
      on E: Exception do
      begin
        found := False;
        UpdateZLog('Exception updating TM data for %d %s', [i, E.Message]);
      end;
    end;
  end;

end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.FuelMessage
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TWMFuel
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.FuelMessage(var Msg: TWMFuel);
var
  ValidPump : boolean;
  DeptNo,
  GradeNo : integer;
  {$IFDEF FF_PROMO}
  FuelFirstCouponCount : integer;
  {$ENDIF}
begin
  DeptNo := 0;
  ValidPump := (Msg.FuelInfo.PumpNo <= NO_PUMPS);
  if ValidPump then
  begin
    if Msg.FuelInfo.PumpNo > 0 then
    begin
      SelPumpIcon :=  nPumpIcons[Msg.FuelInfo.PumpNo];
    end;

    case Msg.FuelInfo.PumpAction of
      PMP_IDLE,
      PMP_AUTHORIZED,
      PMP_STARTFLOW,
      PMP_FLOWING,
      PMP_PAY,
      PMP_COLLECTOK,
      PMP_STACK,
      PMP_CATRESERVE,
      PMP_RESERVEDCOP,
      PMP_RESERVED :
      begin
        SelPumpIcon.CardType          := Msg.FuelInfo.PumpSale1CardTypeNo;
        SelPumpIcon.Sale1Status       := Msg.FuelInfo.PumpSale1Status;
        SelPumpIcon.Sale1Hose         := Msg.FuelInfo.PumpSale1Hose;
        SelPumpIcon.Sale1Type         := Msg.FuelInfo.PumpSale1Type;
        SelPumpIcon.Sale1ID           := Msg.FuelInfo.PumpSale1ID;
        SelPumpIcon.Sale1UnitPrice    := Msg.FuelInfo.PumpSale1UnitPrice;
        SelPumpIcon.Sale1Volume       := Msg.FuelInfo.PumpSale1Volume;
        SelPumpIcon.Sale1Amount       := Msg.FuelInfo.PumpSale1Amount;
        SelPumpIcon.Sale1PrePayAmount := Msg.FuelInfo.PumpSale1PrePayAmount;
        SelPumpIcon.Sale1PresetAmount := Msg.FuelInfo.PumpSale1PresetAmount;
        SelPumpIcon.Sale1CollectTime  := Msg.FuelInfo.PumpSale1CollectTime;
        {$IFDEF ODOT_VMT}
        SelPumpIcon.Sale1VMTFee       := Msg.FuelInfo.PumpSale1VMTFee;
        SelPumpIcon.Sale1VMTReceiptData := Msg.FuelInfo.PumpSale1VMTReceiptData;
        {$ENDIF}

        SelPumpIcon.Sale2Status       := Msg.FuelInfo.PumpSale2Status;
        SelPumpIcon.Sale2Hose         := Msg.FuelInfo.PumpSale2Hose;
        SelPumpIcon.Sale2Type         := Msg.FuelInfo.PumpSale2Type;
        SelPumpIcon.Sale2ID           := Msg.FuelInfo.PumpSale2ID;
        SelPumpIcon.Sale2UnitPrice    := Msg.FuelInfo.PumpSale2UnitPrice;
        SelPumpIcon.Sale2Volume       := Msg.FuelInfo.PumpSale2Volume;
        SelPumpIcon.Sale2Amount       := Msg.FuelInfo.PumpSale2Amount;
        SelPumpIcon.Sale2PrePayAmount := Msg.FuelInfo.PumpSale2PrePayAmount;
        SelPumpIcon.Sale2CollectTime  := Msg.FuelInfo.PumpSale2CollectTime;
        {$IFDEF ODOT_VMT}
        SelPumpIcon.Sale2VMTFee       := Msg.FuelInfo.PumpSale2VMTFee;
        SelPumpIcon.Sale2VMTReceiptData := Msg.FuelInfo.PumpSale2VMTReceiptData;
        {$ENDIF}
      end;

      PMP_CATSTATUSCHANGE :
      begin
        SelPumpIcon.PrinterError     := Msg.FuelInfo.PrinterError;
        SelPumpIcon.PrinterPaperLow  := Msg.FuelInfo.PrinterPaperLow;
        SelPumpIcon.PrinterPaperOut  := Msg.FuelInfo.PrinterPaperOut;
        SelPumpIcon.CATOnline        := Msg.FuelInfo.CATOnLine;
        SelPumpIcon.CATEnabled       := Msg.FuelInfo.CATEnabled;
      end;

      PMP_PAUSED :
      begin
        SelPumpIcon.SavLabelCaption  := SelPumpIcon.LabelCaption;
        SelPumpIcon.LabelCaption := 'Paused';
      end;

      PMP_UNPAUSED :
      begin
        SelPumpIcon.LabelCaption  := SelPumpIcon.SAVLabelCaption;
        SelPumpIcon.SavLabelCaption := '';
      end;
    end;//Case

    case Msg.FuelInfo.PumpAction of
      PMP_IDLE :
      begin
        SelPumpIcon.Play := False;
        SelPumpIcon.Sound := 0;
        SelPumpIcon.PumpOnLine := True;
        if SelPumpIcon.Sale1Status = SAL_RESERVED then
          SelPumpIcon.Frame := FR_RESERVED
        else
          SelPumpIcon.Frame := SelPumpIcon.IdleFrame;
        SelPumpIcon.ButtonColor := clSilver;
        SelPumpIcon.ButtonFont.Color := clBlack;
        SelPumpIcon.ButtonCaption := '';
        SelPumpIcon.ClearSale1;
        if SelPumpIcon.Sale2ID = 0 then
        begin
          SelPumpIcon.LabelFont.Color := clSilver;
          SelPumpIcon.LabelColor := clSilver;
          SelPumpIcon.Refresh;
          SelPumpIcon.LabelCaption := IntToStr(SelPumpIcon.PumpNo);
          SelPumpIcon.LabelFont.Color := clBlack;
        end
        else
        begin
          SelPumpIcon.LabelColor := clRed;
          if SelPumpIcon.Sale2Status = SAL_HELD then
            SelPumpIcon.LabelFont.Color := clGray
          else
            SelPumpIcon.LabelFont.Color := clBlack;
          if SelPumpIcon.Sale2Type = FUELSALETYPE_PREPAYINSIDE then
            SelPumpIcon.LabelCaption := Format('%6.2m',[SelPumpIcon.Sale2Amount - SelPumpIcon.Sale2PrePayAmount])
          else
            SelPumpIcon.LabelCaption := Format('%6.2m',[SelPumpIcon.Sale2Amount]);
        end;
        SelPumpIcon.Refresh;
      end;

      PMP_CALL :
      begin
        SelPumpIcon.Interval := 150;
        SelPumpIcon.Frame := FR_UPSTART ;
        SelPumpIcon.StartFrame := FR_UPSTART + 1;
        SelPumpIcon.EndFrame := FR_UPEND + 1;
        SelPumpIcon.Play := True;
        SelPumpIcon.Sound := SOUND_CALL;
        if (nPumpAuthMode = 2) and (ThisTerminalNo = 1) then   // if auto auth
        begin
          sPumpNo := IntToStr(Msg.FuelInfo.PumpNo);
          ProcessKeyPAT;
        end;
      end;

      PMP_AUTHORIZED :
      begin
        { We only change the icon if it's not a "Pay at the pump"-Sale }
        SelPumpIcon.Sound := 0;
        if SelPumpIcon.Sale1Type in [FUELSALETYPE_CREDITOUTSIDE, FUELSALETYPE_DEBITOUTSIDE, FUELSALETYPE_CASHOUTSIDE] then
        begin
          SelPumpIcon.Play := False;
          case SelPumpIcon.CardType of
            nCT_MASTERCARD : SelPumpIcon.Frame := FR_MCAUTH ;
            nCT_AMEX       : SelPumpIcon.Frame := FR_AMEXAUTH ;
            nCT_DISCOVER   : SelPumpIcon.Frame := FR_DISCAUTH ;
            nCT_WEX        : SelPumpIcon.Frame := FR_WEXAUTH ;
            nCT_DINERS     : SelPumpIcon.Frame := FR_DINERSAUTH;
            nCT_VOYAGER    : SelPumpIcon.Frame := FR_VOYAGERAUTH ;
            nCT_FLEETONE   : SelPumpIcon.Frame := FR_FLEETONEAUTH ;
            nCT_GIFT       : SelPumpIcon.Frame := FR_GIFTAUTH ;
            {$IFDEF FUEL_FIRST}
            nCT_FUEL_FIRST : SelPumpIcon.Frame := FR_FUELFIRSTAUTH ;    // Not needed - included for consistency; (always a pay inside)
            {$ENDIF}
            else
              SelPumpIcon.Frame := FR_VISAAUTH ;
          end;//case
        end
        {$IFDEF FUEL_FIRST}
        else if ((SelPumpIcon.Sale1Type = FUELSALETYPE_PAYINSIDE) and (SelPumpIcon.CardType = nCT_FUEL_FIRST)) then
        begin
          SelPumpIcon.Play := False;
          {$IFDEF FF_PROMO}
          // Check for Fuel First award (use different pump icon frame if coupon awarded).
          try
            POSPrt.PrintFuelFirstCoupon(Msg.FuelInfo.AuthID, False, FuelFirstCouponCount);
          except
            FuelFirstCouponCount := 0;
          end;
          if (FuelFirstCouponCount > 0) then
            SelPumpIcon.Frame := FR_FUELFIRST_AUTH_WIN
          else
          {$ENDIF}
            SelPumpIcon.Frame := FR_FUELFIRSTAUTH ;
          SelPumpIcon.Refresh;
        end
        {$ENDIF}
        else
        begin
          SelPumpIcon.Play := False;
          SelPumpIcon.Frame := FR_AUTHORIZED ;
          if SelPumpIcon.Sale1Type = FUELSALETYPE_PREPAYINSIDE then
          begin
            SelPumpIcon.ButtonColor := clGreen;
            SelPumpIcon.ButtonFont.Color := clYellow;
            SelPumpIcon.ButtonCaption := Format('%6.2m',[SelPumpIcon.Sale1PrePayAmount]);
          end
          else
          begin
            if SelPumpIcon.Sale1PresetAmount > 0 then
              SelPumpIcon.ButtonCaption := Format('%6.2m',[SelPumpIcon.Sale1PresetAmount]);
          end;
        end;
        SelPumpIcon.Refresh;
      end;

      PMP_STARTFLOW :
      begin
        { We only change the icon if it's not a "Pay at the pump"-Sale }
        if SelPumpIcon.Sale1Type in [FUELSALETYPE_CREDITOUTSIDE, FUELSALETYPE_DEBITOUTSIDE, FUELSALETYPE_CASHOUTSIDE] then
        begin
          SelPumpIcon.Play := False;
          case SelPumpIcon.CardType of
            nCT_MASTERCARD : SelPumpIcon.Frame := FR_MCAUTH ;
            nCT_AMEX       : SelPumpIcon.Frame := FR_AMEXAUTH ;
            nCT_DISCOVER   : SelPumpIcon.Frame := FR_DISCAUTH ;
            nCT_WEX        : SelPumpIcon.Frame := FR_WEXAUTH ;
            nCT_DINERS     : SelPumpIcon.Frame := FR_DINERSAUTH;
            nCT_VOYAGER    : SelPumpIcon.Frame := FR_VOYAGERAUTH ;
            nCT_FLEETONE   : SelPumpIcon.Frame := FR_FLEETONEAUTH ;
            nCT_GIFT       : SelPumpIcon.Frame := FR_GIFTAUTH ;
            {$IFDEF FUEL_FIRST}
            nCT_FUEL_FIRST : SelPumpIcon.Frame := FR_FUELFIRSTAUTH ;  // Not needed - included for consistency; (always a pay inside)
            {$ENDIF}
            else
              SelPumpIcon.Frame := FR_VISAAUTH ;
          end;//case
        end
        else                                    { Pay at the Pump - Sale.... }
        begin
          SelPumpIcon.Play := False;
          SelPumpIcon.Interval := 150;
          SelPumpIcon.Frame := FR_FLOWSTART ;
          SelPumpIcon.StartFrame := FR_FLOWSTART + 1;
          SelPumpIcon.EndFrame := FR_FLOWEND + 1;
          SelPumpIcon.Play := True;
          SelPumpIcon.Sale1Type := 0;
        end;
      end;

      PMP_FLOWING :
      begin
        if SelPumpIcon.Sale1Type = FUELSALETYPE_PREPAYINSIDE then
           SelPumpIcon.ButtonCaption := Format('%6.2m',[SelPumpIcon.Sale1PrePayAmount - SelPumpIcon.Sale1Amount])
        else
          SelPumpIcon.ButtonCaption :=  Format('%6.2m',[SelPumpIcon.Sale1Amount]);
        if ((SelPumpIcon.Frame in [FR_FLOWSTART])
            and POSDataMod.IBDB.TestConnected) then
        begin
          if SelPumpIcon.Sale1Hose <> 0 then
          begin
            if not POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.StartTransaction;
            with POSDataMod.IBPumpDefQuery do
            begin
              Close;
              SQL.Clear;
              SQL.Add('Select * from PumpDef where PumpNo = :pPumpNo and HoseNo = :pHoseNo');
              ParamByName('pPumpNo').AsInteger := Msg.FuelInfo.PumpNo;
              ParamByName('pHoseNo').AsInteger := SelPumpIcon.Sale1Hose;
              Open;
              if EOF then
              begin
                Close;
                POSError('PumpDef Not Found');
                GradeNo := 0;
                DeptNo := 0;
              end
              else
              begin
                GradeNo := FieldByName('GradeNo').AsInteger;
                Close;
              end;
            end;
            if GradeNo <> 0 then
              with POSDataMod.IBGradeQuery do
              begin
                Close;
                SQL.Clear;
                SQL.Add('Select * from Grade where GradeNo  = :pGradeNo');
                ParamByName('pGradeNo').AsInteger := GradeNo;
                Open;
                if EOF then
                begin
                  Close;
                  POSError('Grade Not Found');
                  Exit;
                end;
                DeptNo := FieldByName('DeptNo').AsInteger;
                Close;
              end;
            POSDataMod.IBTransaction.Commit;
          end;
          SelPumpIcon.Play := False;
          SelPumpIcon.Interval := 150;
          {$IFDEF PUMP_ICON_EXT}
          if (SelPumpIcon.CardType = nCT_FUEL_FIRST) then
          begin
            {$IFDEF FF_PROMO}
            // Check for Fuel First award (use different pump icon frame if coupon awarded).
            try
              POSPrt.PrintFuelFirstCoupon(Msg.FuelInfo.AuthID, False, FuelFirstCouponCount);
            except
              FuelFirstCouponCount := 0;
            end;
            if (FuelFirstCouponCount > 0) then
            begin
              SelPumpIcon.Frame := FR_FLOWSTARTFUELFIRST_WIN ;
              SelPumpIcon.StartFrame := FR_FLOWSTARTFUELFIRST_WIN + 1;
              SelPumpIcon.EndFrame := FR_FLOWENDFUELFIRST_WIN + 1;
            end
            else
            {$ENDIF}
            begin
              SelPumpIcon.Frame := FR_FLOWSTARTFUELFIRST ;
              SelPumpIcon.StartFrame := FR_FLOWSTARTFUELFIRST + 1;
              SelPumpIcon.EndFrame := FR_FLOWENDFUELFIRST + 1;
            end;
          end // if (SelPumpIcon.CardType = CT_FUEL_FIRST)
          else
          {$ENDIF}
          //20060719 (change 90, 91, 92, 93, 94 to DEPT_NO_...)
          if DeptNo = DEPT_NO_UNLEADED then
          begin
            SelPumpIcon.Frame := FR_FLOWSTARTUNL ;
            SelPumpIcon.StartFrame := FR_FLOWSTARTUNL + 1;
            SelPumpIcon.EndFrame := FR_FLOWENDUNL + 1;
          end
          else if DeptNo = DEPT_NO_PLUS then
          begin
            SelPumpIcon.Frame := FR_FLOWSTARTPLU ;
            SelPumpIcon.StartFrame := FR_FLOWSTARTPLU + 1;
            SelPumpIcon.EndFrame := FR_FLOWENDPLU + 1;
          end
          else if DeptNo = DEPT_NO_SUPER then
          begin
            SelPumpIcon.Frame := FR_FLOWSTARTSUP ;
            SelPumpIcon.StartFrame := FR_FLOWSTARTSUP + 1;
            SelPumpIcon.EndFrame := FR_FLOWENDSUP + 1;
          end
          else if DeptNo = DEPT_NO_DIESEL then
          begin
            SelPumpIcon.Frame := FR_FLOWSTARTDIE ;
            SelPumpIcon.StartFrame := FR_FLOWSTARTDIE + 1;
            SelPumpIcon.EndFrame := FR_FLOWENDDIE + 1;
          end
          else if DeptNo = DEPT_NO_KEROSENE then
          begin
            SelPumpIcon.Frame := FR_FLOWSTARTKER ;
            SelPumpIcon.StartFrame := FR_FLOWSTARTKER + 1;
            SelPumpIcon.EndFrame := FR_FLOWENDKER + 1;
          end
          else
          begin
            SelPumpIcon.Frame := FR_FLOWSTART ;
            SelPumpIcon.StartFrame := FR_FLOWSTART + 1;
            SelPumpIcon.EndFrame := FR_FLOWEND + 1;
          end;
          SelPumpIcon.Play := True;
          SelPumpIcon.Sale1Type := 0;
        end;
      end;

      PMP_RELEASED :
      begin
        if Msg.FuelInfo.SaleID = 0 then
        begin
          SelPumpIcon.Play := False;
          SelPumpIcon.Sound := 0;
          SelPumpIcon.Frame := SelPumpIcon.IdleFrame;
          SelPumpIcon.ButtonFont.Color := clBlack;
          SelPumpIcon.ButtonCaption := '';
          SelPumpIcon.ClearSale1;
        end
        else if Msg.FuelInfo.SaleID = SelPumpIcon.Sale1ID then
        begin
          if (SelPumpIcon.Sale1Type = FUELSALETYPE_PREPAYINSIDE) and
             (SelPumpIcon.Sale1PrePayAmount > SelPumpIcon.Sale1Amount) then
            SelPumpIcon.ButtonFont.Color := clRed
          else
            SelPumpIcon.ButtonFont.Color := clBlack;
          SelPumpIcon.Sound := SOUND_COLLECT;
        end
        else if Msg.FuelInfo.SaleID = SelPumpIcon.Sale2ID then
        begin
          SelPumpIcon.LabelFont.Color := clBlack;
          SelPumpIcon.Sound := SOUND_COLLECT;
        end;
      end;

      PMP_PAY :
      begin
        SelPumpIcon.Sound := SOUND_COLLECT;
        SelPumpIcon.Play := False;
        {$IFDEF PUMP_ICON_EXT}
        if (SelPumpIcon.CardType = nCT_FUEL_FIRST) then
        begin
          {$IFDEF FF_PROMO}
          // Check for Fuel First award (use different pump icon frame if coupon awarded).
          try
            POSPrt.PrintFuelFirstCoupon(Msg.FuelInfo.AuthID, False, FuelFirstCouponCount);
          except
            FuelFirstCouponCount := 0;
          end;
          if (FuelFirstCouponCount > 0) then
            SelPumpIcon.Frame := FR_PAY_FUELFIRST_WIN
          else
          {$ENDIF}
            SelPumpIcon.Frame := FR_PAY_FUELFIRST;
        end // if (SelPumpIcon.CardType = CT_FUEL_FIRST)
        else
        {$ENDIF}
          SelPumpIcon.Frame := FR_PAY;
        if SelPumpIcon.Sale1Type in [FUELSALETYPE_CREDITOUTSIDE, FUELSALETYPE_DEBITOUTSIDE, FUELSALETYPE_CASHOUTSIDE] then
        begin
          SelPumpIcon.Sound := 0;
        end
        else if SelPumpIcon.Sale1Type = FUELSALETYPE_PREPAYINSIDE then
        begin
          if SelPumpIcon.Sale1PrePayAmount = SelPumpIcon.Sale1Amount then
          begin
            SelPumpIcon.ButtonCaption := Format('%6.2m',[0.00]);
            {if the amounts are the same then we can auto-pay}
            if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
              SendFuelMessage(Msg.FuelInfo.PumpNo, PMP_COLLECTASK, NOAMOUNT, SelPumpIcon.Sale1ID, NOTRANSNO, NODESTPUMP );
          end
          else
          begin
            SelPumpIcon.ButtonFont.Color := clRed;
            SelPumpIcon.ButtonCaption := Format('%6.2m',[SelPumpIcon.Sale1Amount - SelPumpIcon.Sale1PrePayAmount]);
          end;
        end
        else
        begin
          SelPumpIcon.ButtonCaption := Format('%6.2m',[SelPumpIcon.Sale1Amount]);
        end;
      end;

      PMP_STOPPED : //      , PMP_PAUSED :
      begin
        SelPumpIcon.Play := False;
        SelPumpIcon.Frame := FR_STOP;
      end;

      PMP_WARN :
      begin
        SelPumpIcon.Play := False;
        SelPumpIcon.Interval := 500;
        SelPumpIcon.Frame := FR_WARNSTART;
        SelPumpIcon.StartFrame := FR_WARNSTART + 1;
        SelPumpIcon.EndFrame := FR_WARNEND + 1;
        SelPumpIcon.Play := True;
      end;

      PMP_DRIVEOFF :
      begin
        SelPumpIcon.Sound := SOUND_DRIVEOFF;
        SelPumpIcon.Play := False;
        SelPumpIcon.Frame := FR_DRIVEOFF ;
      end;

      PMP_RESERVED, PMP_CATRESERVE, PMP_RESERVEDCOP :
      begin
        SelPumpIcon.Play := False;
        SelPumpIcon.Sound := 0;
        if Msg.FuelInfo.PumpAction = PMP_RESERVED then
        Begin
          SelPumpIcon.Frame := FR_RESERVED ;
          if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
          begin
            New(ProcessPrePayMsg);
            ProcessPrePayMsg.PumpNo       := SelPumpIcon.PumpNo;
            ProcessPrePayMsg.PrePayAmount := SelPumpIcon.Sale1PrePayAmount;
            PostMessage(fmPOS.Handle, WM_PROCESSPREPAY, 0, LongInt(ProcessPrePayMsg));
          end;
        End
        else if Msg.FuelInfo.PumpAction = PMP_RESERVEDCOP then
        Begin
          SelPumpIcon.Frame := FR_RESERVED ;
          if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
          begin
            New(COPMsg);
            COPMsg.PumpNo := SelPumpIcon.PumpNo;
            COPMsg.PrePayAmount := SelPumpIcon.Sale1PrePayAmount;
            PostMessage(fmPOS.Handle, WM_COPMSG, 0, LongInt(COPMsg));
          end;
        End
        else if Msg.FuelInfo.PumpAction = PMP_CATRESERVE Then
        Begin
          case SelPumpIcon.CardType of
            nCT_MASTERCARD : SelPumpIcon.Frame := FR_MC ;
            nCT_AMEX       : SelPumpIcon.Frame := FR_AMEX ;
            nCT_DISCOVER   : SelPumpIcon.Frame := FR_DISC ;
            nCT_WEX        : SelPumpIcon.Frame := FR_WEX ;
            nCT_DINERS     : SelPumpIcon.Frame := FR_DINERS;
            nCT_VOYAGER    : SelPumpIcon.Frame := FR_VOYAGER ;
            nCT_FLEETONE   : SelPumpIcon.Frame := FR_FLEETONE ;
            nCT_GIFT       : SelPumpIcon.Frame := FR_GIFT ;
            {$IFDEF FUEL_FIRST}
            nCT_FUEL_FIRST : SelPumpIcon.Frame := FR_FUELFIRST ;
            {$ENDIF}
            else
              SelPumpIcon.Frame := FR_VISA ;
          end;//case
        End;
        SelPumpIcon.ButtonFont.Color := clBlack;
        SelPumpIcon.ButtonCaption := '';
        SelPumpIcon.Sale1ID := 0;
        SelPumpIcon.Refresh;
      end;

      PMP_COLLECTMULTIPLE :
      begin
        if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
          PostMessage(fmPOS.Handle, WM_SELECTFUELSALE, 0, LongInt(SelPumpIcon.PumpNo));
      end;

      PMP_COLLECTOK :
      begin
        SelPumpIcon.Sound := 0;
        //Gift
        //SaleNo := 0;
        //Gift
        if Msg.FuelInfo.SaleID = SelPumpIcon.Sale1ID then
        begin
          SelPumpIcon.Play := False;
          SelPumpIcon.Frame := FR_PAY;
          SelPumpIcon.ButtonFont.Color := clGray;
          If SelPumpIcon.Sale1Type in [FUELSALETYPE_CREDITOUTSIDE, FUELSALETYPE_DEBITOUTSIDE, FUELSALETYPE_CASHOUTSIDE] Then
          Begin
          End
          else if SelPumpIcon.Sale1Type = FUELSALETYPE_PREPAYINSIDE then
          begin
            if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
            begin
              if (SelPumpIcon.Sale1PrePayAmount = SelPumpIcon.Sale1Amount) then
              begin
                New(PostPrePayMsg);
                PostPrePayMsg.PumpNo       := SelPumpIcon.PumpNo;
                PostPrePayMsg.HoseNo       :=  SelPumpIcon.Sale1Hose;
                PostPrePayMsg.SaleID       :=  SelPumpIcon.Sale1ID;
                PostPrePayMsg.SaleVolume   :=  SelPumpIcon.Sale1Volume;
                PostPrePayMsg.SaleAmount   :=  SelPumpIcon.Sale1Amount;
                PostPrePayMsg.PrePayAmount :=  SelPumpIcon.Sale1PrePayAmount;
                PostMessage(fmPOS.Handle, WM_POSTPREPAY, 0, LongInt(PostPrePayMsg));
              end
              else
              begin
                New(ProcessPrePayRefundMsg);
                ProcessPrePayRefundMsg.PumpNo       := SelPumpIcon.PumpNo;
                ProcessPrePayRefundMsg.SaleID       := SelPumpIcon.Sale1ID;
                ProcessPrePayRefundMsg.RefundAmount := SelPumpIcon.Sale1Amount - SelPumpIcon.Sale1PrePayAmount;
                PostMessage(fmPOS.Handle, WM_PROCESSPREPAYREFUND, 0, LongInt(ProcessPrePayRefundMsg));
              end;
            end;
          end
          else
          begin
            if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
            begin
              New(ProcessFuelMsg);
              ProcessFuelMsg.PumpNo := SelPumpIcon.PumpNo;
              ProcessFuelMsg.HoseNo := SelPumpIcon.Sale1Hose;
              ProcessFuelMsg.SaleID := SelPumpIcon.Sale1ID;
              ProcessFuelMsg.UnitPrice  := SelPumpIcon.Sale1UnitPrice;
              ProcessFuelMsg.SaleVolume := SelPumpIcon.Sale1Volume;
              ProcessFuelMsg.SaleAmount := SelPumpIcon.Sale1Amount;
              {$IFDEF FUEL_FIRST}
              //20061107a...
//              ProcessFuelMsg.AuthID := Msg.FuelInfo.AuthID; //  PumpCATInfo[Msg.FuelInfo.PumpNo].AuthID
              ProcessFuelMsg.AuthID := Msg.FuelInfo.PumpSale1AuthID; //  PumpCATInfo[Msg.FuelInfo.PumpNo].AuthID
              //...20061107a
              ProcessFuelMsg.CardType := Msg.FuelInfo.PumpSale1CardTypeNo;
              {$ENDIF}
              {$IFDEF ODOT_VMT}
              ProcessFuelMsg.VMTFee := SelPumpIcon.Sale1VMTFee;
              ProcessFuelMsg.VMTReceiptData := SelPumpIcon.Sale1VMTReceiptData;
              {$ENDIF}
              PostMessage(fmPOS.Handle, WM_PROCESSFUEL, 0, LongInt(ProcessFuelMsg));
            end;
          end;
        end
        else if Msg.FuelInfo.SaleID = SelPumpIcon.Sale2ID then
        begin
          SelPumpIcon.LabelFont.Color := clGray;
          If SelPumpIcon.Sale2Type in [FUELSALETYPE_CREDITOUTSIDE, FUELSALETYPE_DEBITOUTSIDE, FUELSALETYPE_CASHOUTSIDE] Then
          Begin
          End
          else if SelPumpIcon.Sale2Type = FUELSALETYPE_PREPAYINSIDE then
          begin
            if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
            begin
              if (SelPumpIcon.Sale2PrePayAmount = SelPumpIcon.Sale2Amount) then
              begin
                New(PostPrePayMsg);
                PostPrePayMsg.PumpNo       := SelPumpIcon.PumpNo;
                PostPrePayMsg.HoseNo       :=  SelPumpIcon.Sale2Hose;
                PostPrePayMsg.SaleID       :=  SelPumpIcon.Sale2ID;
                PostPrePayMsg.SaleVolume   :=  SelPumpIcon.Sale2Volume;
                PostPrePayMsg.SaleAmount   :=  SelPumpIcon.Sale2Amount;
                PostPrePayMsg.PrePayAmount :=  SelPumpIcon.Sale2PrePayAmount;
                PostMessage(fmPOS.Handle, WM_POSTPREPAY, 0, LongInt(PostPrePayMsg));
              end
              else
              begin
                New(ProcessPrePayRefundMsg);
                ProcessPrePayRefundMsg.PumpNo       := SelPumpIcon.PumpNo;
                ProcessPrePayRefundMsg.SaleID       := SelPumpIcon.Sale2ID;
                ProcessPrePayRefundMsg.RefundAmount := SelPumpIcon.Sale2Amount - SelPumpIcon.Sale2PrePayAmount;
                PostMessage(fmPOS.Handle, WM_PROCESSPREPAYREFUND, 0, LongInt(ProcessPrePayRefundMsg));
              end;
            end;
          end
          else
          begin
            if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
            begin
              New(ProcessFuelMsg);
              ProcessFuelMsg.PumpNo     := SelPumpIcon.PumpNo;
              ProcessFuelMsg.HoseNo     := SelPumpIcon.Sale2Hose;
              ProcessFuelMsg.SaleID     := SelPumpIcon.Sale2ID;
              ProcessFuelMsg.UnitPrice  := SelPumpIcon.Sale2UnitPrice;
              ProcessFuelMsg.SaleVolume := SelPumpIcon.Sale2Volume;
              ProcessFuelMsg.SaleAmount := SelPumpIcon.Sale2Amount;
              {$IFDEF FUEL_FIRST}
              //20061107a...
//              ProcessFuelMsg.AuthID := Msg.FuelInfo.AuthID;  // PumpCATInfo[Msg.FuelInfo.PumpNo].AuthID
              ProcessFuelMsg.AuthID := Msg.FuelInfo.PumpSale2AuthID;  // PumpCATInfo[Msg.FuelInfo.PumpNo].AuthID
              //...20061107a
              ProcessFuelMsg.CardType := Msg.FuelInfo.PumpSale2CardTypeNo;
              {$ENDIF}
              {$IFDEF ODOT_VMT}
              ProcessFuelMsg.VMTFee := SelPumpIcon.Sale2VMTFee;
              ProcessFuelMsg.VMTReceiptData := SelPumpIcon.Sale2VMTReceiptData;
              {$ENDIF}
              PostMessage(fmPOS.Handle, WM_PROCESSFUEL, 0, LongInt(ProcessFuelMsg));
            end;
          end;
        end;
      end;

      PMP_PAIDSALE :
      begin
        if Msg.FuelInfo.SaleID = SelPumpIcon.Sale1ID then
        begin
          if SelPumpIcon.Sale1Type = FUELSALETYPE_PREPAYINSIDE then
          begin
            if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
              if SelPumpIcon.Sale1PrePayAmount <> SelPumpIcon.Sale1Amount then
              begin
                New(PostPrePayMsg);
                PostPrePayMsg.PumpNo       :=  SelPumpIcon.PumpNo;
                PostPrePayMsg.HoseNo       :=  SelPumpIcon.Sale1Hose;
                PostPrePayMsg.SaleID       :=  SelPumpIcon.Sale1ID;
                PostPrePayMsg.SaleVolume   :=  SelPumpIcon.Sale1Volume;
                PostPrePayMsg.SaleAmount   :=  SelPumpIcon.Sale1Amount;
                PostPrePayMsg.PrePayAmount :=  SelPumpIcon.Sale1PrePayAmount;
                PostMessage(fmPOS.Handle, WM_POSTPREPAY, 0, LongInt(PostPrePayMsg));
              end;
          end;
          SelPumpIcon.Play := False;
          SelPumpIcon.Frame := SelPumpIcon.IdleFrame;
          SelPumpIcon.ButtonColor := clSilver;
          SelPumpIcon.ButtonFont.Color := clSilver;
          SelPumpIcon.Refresh;
          SelPumpIcon.ButtonCaption := '';
          SelPumpIcon.ButtonFont.Color := clBlack;
          SelPumpIcon.ClearSale1;
          SelPumpIcon.Sound := 0;
        end
        else if Msg.FuelInfo.SaleID = SelPumpIcon.Sale2ID then
        begin
          if SelPumpIcon.Sale2Type = FUELSALETYPE_PREPAYINSIDE then
          begin
            if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
              if SelPumpIcon.Sale2PrePayAmount <> SelPumpIcon.Sale2Amount then
              begin
                New(PostPrePayMsg);
                PostPrePayMsg.PumpNo       :=  SelPumpIcon.PumpNo;
                PostPrePayMsg.HoseNo       :=  SelPumpIcon.Sale2Hose;
                PostPrePayMsg.SaleID       :=  SelPumpIcon.Sale2ID;
                PostPrePayMsg.SaleVolume   :=  SelPumpIcon.Sale2Volume;
                PostPrePayMsg.SaleAmount   :=  SelPumpIcon.Sale2Amount;
                PostPrePayMsg.PrePayAmount :=  SelPumpIcon.Sale2PrePayAmount;
                PostMessage(fmPOS.Handle, WM_POSTPREPAY, 0, LongInt(PostPrePayMsg));
              end;
          end;
          SelPumpIcon.LabelFont.Color := clSilver;
          SelPumpIcon.Refresh;
          SelPumpIcon.LabelCaption := IntToStr(SelPumpIcon.PumpNo);
          SelPumpIcon.LabelFont.Color := clBlack;
          SelPumpIcon.LabelColor := clSilver;
          SelPumpIcon.Refresh;
          SelPumpIcon.ClearSale2;
          SelPumpIcon.Sound := 0;
        end;
      end;

      PMP_STACK :
      begin
        SelPumpIcon.ButtonColor := clSilver;
        SelPumpIcon.ButtonFont.Color := clBlack;
        SelPumpIcon.LabelColor := clRed;
        if SelPumpIcon.Sale2Status = SAL_HELD then
          SelPumpIcon.LabelFont.Color := clGray
        else
          SelPumpIcon.LabelFont.Color := clBlack;
        if SelPumpIcon.Sale2Type = FUELSALETYPE_PREPAYINSIDE then
          SelPumpIcon.LabelCaption := Format('%6.2m',[SelPumpIcon.Sale2Amount - SelPumpIcon.Sale2PrePayAmount])
        else
          SelPumpIcon.LabelCaption := Format('%6.2m',[SelPumpIcon.Sale2Amount]);
      end;

      PMP_COMMDOWN :
      begin
        SelPumpIcon.Play := False;
        SelPumpIcon.PumpOnLine := False;
        SelPumpIcon.Frame := FR_COMMDOWN;
      end;

      PMP_CATSHOWHELP :
      begin
        SelPumpIcon.HelpShowing := True;
        MakeNoise(CATHELPSOUND);
      end;

      PMP_CATSTATUSCHANGE :
      begin
        SelPumpIcon.CheckCATStatus;
      end;

      PMP_EXCEPTION :
      begin
        if Msg.FuelInfo.TerminalNo = ThisTerminalNo then
        begin
          case Msg.FuelInfo.PumpError of
            ERR_NOSTACKSPACE :
            begin
              POSError('No More Stack Sales For Pump# ' + IntToStr(Msg.FuelInfo.PumpNo));
            end;
            ERR_NOPUMPSALES :
            begin
              if Msg.FuelInfo.PumpErrorMsg > '' then
                POSError(Msg.FuelInfo.PumpErrorMsg)
              else
                POSError('No Sales Ready To Collect On Pump# ' + IntToStr(Msg.FuelInfo.PumpNo));
            end;
            ERR_BADSALEID :
            begin
              POSError('Bad Fuel Sale ID - Pump# ' + IntToStr(Msg.FuelInfo.PumpNo) + ' ID# '
                                                   + Format('%6.6d',[Msg.FuelInfo.SaleID])) ;
            end;
            ERR_SALENOTAVAILABLE :
            begin
              if Msg.FuelInfo.PumpErrorMsg > '' then
                POSError(Msg.FuelInfo.PumpErrorMsg)
              else
                POSError('No Sale Available On Pump# ' + IntToStr(Msg.FuelInfo.PumpNo));
            end;
            ERR_PUMPNOTAVAILABLE :
            begin
              POSError('Pump# ' + IntToStr(Msg.FuelInfo.PumpNo) + ' Not Available');
            end;
            ERR_HOSENOTAVAILABLE :
            begin
              POSError('Pump# ' + IntToStr(Msg.FuelInfo.PumpNo) + ' Hose Not Available');
            end;
          end;//Case
          ClearEntryField;
        end;
      end;

      PMP_TOTALSREAD :
      begin
        if fFuelTotals then
        begin
          nFuelTotalID := Msg.FuelInfo.PumpTotalID;
          fFuelTotals := False;
        end;
      end;
    end;   {end case}
  end;
  Dispose(Msg.FuelInfo);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.SelectFuelSale
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg : TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.SelectFuelSale(var Msg : TMessage);
var
PI : TPumpxIcon;
begin
  fmFuelSelect.PumpNo              := Msg.LParam;
  PI                               := nPumpIcons[fmFuelSelect.PumpNo];

  fmFuelSelect.SaleHose[1]         := PI.Sale1Hose          ;
  fmFuelSelect.SaleType[1]         := PI.Sale1Type          ;
  fmFuelSelect.SaleAmount[1]       := PI.Sale1Amount        ;
  fmFuelSelect.SalePrePayAmount[1] := PI.Sale1PrePayAmount  ;
  fmFuelSelect.SaleVolume[1]       := PI.Sale1Volume        ;
  fmFuelSelect.SaleID[1]           := PI.Sale1ID            ;
  fmFuelSelect.SaleCollectTime[1]  := PI.Sale1CollectTime   ;

  fmFuelSelect.SaleHose[2]         := PI.Sale2Hose          ;
  fmFuelSelect.SaleType[2]         := PI.Sale2Type          ;
  fmFuelSelect.SaleAmount[2]       := PI.Sale2Amount        ;
  fmFuelSelect.SalePrePayAmount[2] := PI.Sale2PrePayAmount  ;
  fmFuelSelect.SaleVolume[2]       := PI.Sale2Volume        ;
  fmFuelSelect.SaleID[2]           := PI.Sale2ID            ;
  fmFuelSelect.SaleCollectTime[2]  := PI.Sale2CollectTime   ;

  fmFuelSelect.ItemSelected := False;
  fmFuelSelect.Show;
  while fmFuelSelect.Visible = True do
  begin
    Application.ProcessMessages;
    sleep(20);
  end;
  if fmFuelSelect.ItemSelected = True then
    SendFuelMessage(nSelectedPumpNo, PMP_COLLECTSELECT, NOAMOUNT, nSelectedSaleID, NOTRANSNO, NODESTPUMP );
  KeyBuff := ' ';
  BuffPtr := 0;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FSSocket1ReceiveMessage
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Orig: string; TerminalNo : Integer; Msg: string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
//procedure TfmPOS.FSSocket1ReceiveMessage(Orig: string; TerminalNo : Integer; Msg: string);
procedure TfmPOS.FSSocket1ReceiveMessage(var XMsg : TMEssage);
var
  pCardType, PPump, pAction, PHose, PSaleType, PAmt, PPrePayAmt, pPresetAmt, PVolume, pUnitPrice : string;
  pErr, pErrMsg, pSaleID, pTotalID, pStatus : string;
  pAuthID : string;
  {$IFDEF ODOT_VMT}
  pVMTFee : string;
  pVMTReceiptData : WideString;
  {$ENDIF}
  {$IFDEF CAT_SIMULATION}
  jPAction : integer;
  {$ENDIF}
  Msg, Orig : string;
  InData : pFSData;
  FSL : Tlist;
  FI : PFuelInfo;
begin
  InData := nil;
  try
    FSL := FSList.LockList();
    FSL.Pack;
    if FSL.Count > 0 then
    begin
      InData := FSL.First();
      FSL.Delete(0);
    end;
  finally
    FSList.UnlockList();
  end;
  if indata <> nil then
  begin
    Msg := InData^.Msg;
    Orig := Indata^.Orig;
    dispose(InData);
    //UpdateZLog('Fuel Message Received: %s', [DeformatFuelMsg(Msg)]);
    if Length(Msg) > 2 then
      begin
        PPump       := GetTagData(FSTAG_PUMPNO, Msg);
        PAction     := GetTagData(FSTAG_PUMPACTION, Msg);
        {$IFDEF CAT_SIMULATION}
        jPAction := StrToInt(PAction);
        // Check for CAT simulation messages relayed from fuel server (only for development/demo).
        if (jPAction in [PMP_CAT_SIMULATE_BEGIN, PMP_CAT_SIMULATE_END]) then
        begin
          // For beginning and ending CAT simulation, just flag the event.
          bCATSimulation := (jPAction = PMP_CAT_SIMULATE_BEGIN);
          exit;
        end
        else if (bCATSimulation and (jPAction = PMP_CAT_SIMULATE_PRINT)) then
        begin
          // Print a line on the printer.
          // (It is user's responsibility to avoid colisions of print data form POS.)
          POSPrt.PrintLine(GetTagData(FSTAG_CAT_SIMULATE_PRINT, Msg));
        end;
        {$ENDIF}

        if StrToInt(PAction) = FS_TMREADINGS then
        begin
          updateZLog('Updating tank monitor readings');
          self.UpdateTMDisplay(Msg);
          exit;
        end;

        New(FI);
        FI^.PumpNo := StrToIntDef(PPump, 0);
        FI^.PumpAction := StrToInt(PAction);

        FI^.TerminalNo := StrToIntDef(GetTagData(FSTAG_TerminalNo, Msg), 0);

        if FI^.PumpAction = FS_STOPPOS then
        begin
          if ThisTerminalNo > 1 then
            begin
              while (bPostingSale or bPostingCATSale or bPostingPrePaySale)  do
                begin
                  application.processmessages;
                  sleep(20);
                end;
              bPOSForceClose := True;
              Close;
            end;
        end
        else if FI^.PumpAction = PMP_EXCEPTION then
        begin
          { Fuel Exception
          123456
          aabbcc
          where
          aa        Pump Number
          bb        Exception Status
          cc        Error Number}
          pErr := GetTagData(FSTAG_PUMPERRORCODE, Msg);;
          try
            FI^.PumpError := StrToInt(PErr);
          except
            FI^.PumpError := 0;
          end;
          pErrMsg := GetTagData(FSTAG_PUMPERRORMSG, Msg);;
          try
            FI^.PumpErrorMsg := PErrMsg;
          except
            FI^.PumpErrorMsg := '';
          end;

          pSaleID        := GetTagData(FSTAG_SALEID, Msg);;
          try
            FI^.SaleID := StrToInt(PSaleID);
          except
            FI^.SaleID := 0;
          end;


        end

        else if FI^.PumpAction = PMP_CATSTATUSCHANGE then
        begin
          try
            FI^.PrinterError := Boolean(StrToInt(GetTagData(FSTAG_RdrPrinterError, Msg)));
          except
            FI^.PrinterError := False;
          end;

          try
            FI^.PrinterPaperLow := Boolean(StrToInt(GetTagData(FSTAG_RdrPaperLow, Msg)));
          except
            FI^.PrinterPaperLow := False;
          end;

          try
            FI^.PrinterPaperOut := Boolean(StrToInt(GetTagData(FSTAG_RdrPaperEmpty, Msg)));
          except
            FI^.PrinterPaperOut := False;
          end;

          try
            FI^.CATOnLine := Boolean(StrToInt(GetTagData(FSTAG_RdrInitialized, Msg)));
          except
            FI^.CATOnLine := False;
          end;

          try
            FI^.CATEnabled := Boolean(StrToInt(GetTagData(FSTAG_RdrExists, Msg)));
          except
            FI^.CATEnabled := False;
          end;

        end

        else if FI^.PumpAction = PMP_TOTALSREAD then
        begin
          { Totals Read
          1234567890
          aabbcc
          where
           aa        Pump Number
           bb        Exception Status
           cccccc    Fuel Totals Number
          }
          pTotalID := GetTagData(FSTAG_PUMPTOTALID, Msg);;
          try
            FI^.PumpTotalID := StrToInt(pTotalID);
          except
            FI^.PumpTotalID := 0;
          end;
        end
        else if (FI^.PumpAction = PMP_COLLECTMULTIPLE) then
        begin

          {
                   1         2         3         4         5         6         7         8         9        10        11
          123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
          aabbxcdeeeeeeffffffggggggghhhhhhtttttttttttcdeeeeeeffffffggggggghhhhhhtttttttttttcdeeeeeeffffffggggggghhhhhhttttttttttt
          where
           aa        Pump Number
           bb        Pump Status
           x         Sale Number ( 0,1,2 or 3 ) 0 only if response on collect multiple

           c         1 Hose Number
           d         1 Sale Type
           eeeeee    1 Sale Amount    999.99
           ffffff    1 Pre Pay Amount 999.99
           ggggggg   1 Sale Volume    999.999
           hhhhhh    1 SaleID         999999
           ttttttttttt1 Sale Collect Time

           c         2 Hose Number
           d         2 Sale Type
           eeeeee    2 Sale Amount    999.99
           ffffff    2 Pre Pay Amount 999.99
           ggggggg   2 Sale Volume    999.999
           hhhhhh    2 SaleID         999999
           ttttttttttt1 Sale Collect Time

           c         3 Hose Number
           d         3 Sale Type
           eeeeee    3 Sale Amount    999.99
           ffffff    3 Pre Pay Amount 999.99
           ggggggg   3 Sale Volume    999.999
           hhhhhh    3 SaleID         999999
           ttttttttttt1 Sale Collect Time}



        end
        else
        begin
          {
                   1         2         3
          123456789012345678901234567890123456
          aabbxcdeeeeeeffffffggggggghhhhhhiiiiiii
          where
           aa        Pump Number
           bb        Action
           x         Status
           c         Hose Number
           d         Sale Type
           eeeeee    Sale Amount    999.99
           ffffff    Pre Pay Amount 999.99
           ggggggg   Sale Volume    999.999
           hhhhhh    SaleID         999999
           iiiiiii   UnitPrice      999.999
          }
          pSaleID        := GetTagData(FSTAG_SALEID, Msg);
          if pSaleID <> '' then
            begin
              try
                FI^.SaleID := StrToInt(pSaleID);
              except
                FI^.SaleID := 0;
              end;
            end;

          PStatus        := GetTagData(FSTAG_PUMPSALE1STATUS, Msg);;
          PHose          := GetTagData(FSTAG_PUMPSALE1HOSE, Msg);;
          PSaleType      := GetTagData(FSTAG_PUMPSALE1TYPE, Msg);;
          pAmt           := GetTagData(FSTAG_PUMPSALE1AMOUNT, Msg);;
          pPrePayAmt     := GetTagData(FSTAG_PUMPSALE1PREPAYAMOUNT, Msg);
          pPresetAmt     := GetTagData(FSTAG_PUMPSALE1PRESETAMOUNT, Msg);
          pVolume        := GetTagData(FSTAG_PUMPSALE1VOLUME, Msg);
          pSaleID        := GetTagData(FSTAG_PUMPSALE1ID, Msg);
          pUnitPrice     := GetTagData(FSTAG_PUMPSALE1UNITPRICE, Msg);

          if pStatus <> '' then
            begin
              try
                FI^.PumpSale1Status := StrToInt(PStatus);
              except
                FI^.PumpSale1Status := 0;
              end;
            end;
          if pHose <> '' then
            begin
              try
                FI^.PumpSale1Hose := StrToInt(PHose);
              except
                FI^.PumpSale1Hose := 0;
              end;
            end;
          if pSaleType <> '' then
            begin
              try
                FI^.PumpSale1Type := StrToInt(PSaleType);
              except
                FI^.PumpSale1Type := 0;
              end;
            end;
          if pAmt <> '' then
            begin
              try
                FI^.PumpSale1Amount := StrToCurr(PAmt);
              except
                FI^.PumpSale1Amount := 0;
              end;
            end;
          if pPrePayAmt <> '' then
            begin
              try
                FI^.PumpSale1PrePayAmount := StrToCurr(PPrePayAmt);
              except
                FI^.PumpSale1PrePayAmount := 0;
              end;
            end;
          if pPresetAmt <> '' then
            begin
              try
                FI^.PumpSale1PresetAmount := StrToCurr(pPresetAmt);
              except
                FI^.PumpSale1PresetAmount := 0;
              end;
            end;
          if pVolume <> '' then
            begin
              try
                FI^.PumpSale1Volume := StrToCurr(PVolume);
              except
                FI^.PumpSale1Volume := 0;
              end;
            end;

          if pSaleID <> '' then
            begin
              try
                FI^.PumpSale1ID := StrToInt(PSaleID);
              except
                FI^.PumpSale1ID := 0;
              end;
            end;

          if pUnitPrice <> '' then
            begin
              try
                FI^.PumpSale1UnitPrice := StrToCurr(PUnitPrice);
              except
                FI^.PumpSale1UnitPrice := 0;
              end;
            end;

          //Gift
          pAuthID      := GetTagData(FSTAG_AUTHID, Msg);
          if (pAuthID <> '') then
            begin
              try
                FI^.AuthID := StrToInt(pAuthID);
              except
                FI^.AuthID := 0;
              end;
            end
          else
            begin
                FI^.AuthID := 0;
            end;
          //Gift
          {$IFDEF FUEL_FIRST}  //20061107a
          pCardType      := GetTagData(FSTAG_PumpSale1CardType, Msg);
          if (pCardType <> '') then
            begin
              try
                FI^.PumpSale1CardTypeNo := StrToInt(pCardType);
              except
                FI^.PumpSale1CardTypeNo := 0;
              end;
            end
          else
            begin
                FI^.PumpSale1CardTypeNo := 0;
            end;
          pCardType      := GetTagData(FSTAG_PumpSale2CardType, Msg);
          if (pCardType <> '') then
            begin
              try
                FI^.PumpSale2CardTypeNo := StrToInt(pCardType);
              except
                FI^.PumpSale2CardTypeNo := 0;
              end;
            end
          else
            begin
                FI^.PumpSale2CardTypeNo := 0;
            end;
          pAuthID      := GetTagData(FSTAG_PumpSale1AUTHID, Msg);
          if (pAuthID <> '') then
            begin
              try
                FI^.PumpSale1AuthID := StrToInt(pAuthID);
              except
                FI^.PumpSale1AuthID := 0;
              end;
            end
          else
            begin
                FI^.PumpSale1AuthID := 0;
            end;
          pAuthID      := GetTagData(FSTAG_PumpSale2AUTHID, Msg);
          if (pAuthID <> '') then
            begin
              try
                FI^.PumpSale2AuthID := StrToInt(pAuthID);
              except
                FI^.PumpSale2AuthID := 0;
              end;
            end
          else
            begin
                FI^.PumpSale2AuthID := 0;
            end;
          {$ENDIF}

          try
            FI^.PumpSale1CollectTime := StrToTime(GetTagData(FSTAG_PUMPSALE1COLLECTTIME, Msg)  );
          except
            FI^.PumpSale1CollectTime := 0;
          end;

          {$IFDEF ODOT_VMT}
          try
            FI^.PumpSale1VMTFee := StrToCurr( GetTagData( FSTAG_PUMPSALE1VMTFEE, Msg ) );
          except
            FI^.PumpSale1VMTFee := 0;
          end;

          try
            FI^.PumpSale1VMTReceiptData := GetTagData( FSTAG_PUMPSALE1VMTRECEIPTDATA, Msg );
          except
            FI^.PumpSale1VMTReceiptData := '';
          end;
          {$ENDIF}

          PStatus        := GetTagData(FSTAG_PUMPSALE2STATUS, Msg);;
          PHose          := GetTagData(FSTAG_PUMPSALE2HOSE, Msg);;
          PSaleType      := GetTagData(FSTAG_PUMPSALE2TYPE, Msg);;
          pAmt           := GetTagData(FSTAG_PUMPSALE2AMOUNT, Msg);;
          pPrePayAmt     := GetTagData(FSTAG_PUMPSALE2PREPAYAMOUNT, Msg);
          pVolume        := GetTagData(FSTAG_PUMPSALE2VOLUME, Msg);
          pSaleID        := GetTagData(FSTAG_PUMPSALE2ID, Msg);
          pUnitPrice     := GetTagData(FSTAG_PUMPSALE2UNITPRICE, Msg);
          {$IFDEF ODOT_VMT}
          pVMTFee        := GetTagData(FSTAG_PUMPSALE2VMTFEE, Msg );
          pVMTReceiptData := GetTagData(FSTAG_PUMPSALE2VMTRECEIPTDATA, Msg);
          {$ENDIF}

          if pStatus <> '' then
          begin
            try
              FI^.PumpSale2Status := StrToInt(PStatus);
            except
              FI^.PumpSale2Status := 0;
            end;
          end;
          if pHose <> '' then
          begin
            try
              FI^.PumpSale2Hose := StrToInt(PHose);
            except
              FI^.PumpSale2Hose := 0;
            end;
          end;
          if pSaleType <> '' then
          begin
            try
              FI^.PumpSale2Type := StrToInt(PSaleType);
            except
              FI^.PumpSale2Type := 0;
            end;
          end;
          if pAmt <> '' then
          begin
            try
              FI^.PumpSale2Amount := StrToCurr(PAmt);
            except
              FI^.PumpSale2Amount := 0;
            end;
          end;
          if pPrePayAmt <> '' then
          begin
            try
              FI^.PumpSale2PrePayAmount := StrToCurr(PPrePayAmt);
            except
              FI^.PumpSale2PrePayAmount := 0;
            end;
          end;
          if pVolume <> '' then
          begin
            try
              FI^.PumpSale2Volume := StrToCurr(PVolume);
            except
              FI^.PumpSale2Volume := 0;
            end;
          end;

          if pSaleID <> '' then
          begin
            try
              FI^.PumpSale2ID := StrToInt(PSaleID);
            except
              FI^.PumpSale2ID := 0;
            end;
          end;

          if pUnitPrice <> '' then
          begin
            try
              FI^.PumpSale2UnitPrice := StrToCurr(PUnitPrice);
            except
              FI^.PumpSale2UnitPrice := 0;
            end;
          end;
          try
            FI^.PumpSale2CollectTime := StrToTime(GetTagData(FSTAG_PUMPSALE2COLLECTTIME, Msg)  );
          except
            FI^.PumpSale2CollectTime := 0;
          end;
          {$IFDEF ODOT_VMT}
          try
            FI^.PumpSale2VMTFee := StrToCurr( GetTagData( FSTAG_PUMPSALE2VMTFEE, Msg ) );
          except
            FI^.PumpSale2VMTFee := 0;
          end;

          try
            FI^.PumpSale2VMTReceiptData := GetTagData( FSTAG_PUMPSALE2VMTRECEIPTDATA, Msg );
          except
            FI^.PumpSale2VMTReceiptData := '';
          end;
          {$ENDIF}

        end;
        PostMessage(fmPOS.Handle, WM_FUELMSG, 0, LongInt(FI));
      end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPRF
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPRF;
var
  pNo :short;
begin
  //20060531...
  if sPumpNo <> '' then  // Added catch for empty string
  begin
  //...20060531
    pNo := StrToInt(sPumpNo);
    SelPumpIcon :=  nPumpIcons[PNo];
    if not (SelPumpIcon.Frame in [FR_AUTHORIZED, FR_VISAAUTH,
                                     FR_MCAUTH, FR_DISCAUTH,
                                     FR_AMEXAUTH, FR_FLEETONEAUTH,
                                     FR_VOYAGERAUTH, FR_WEXAUTH,
                                     FR_GIFTAUTH, FR_DINERSAUTH,
                                     {$IFDEF FUEL_FIRST}
                                     FR_FUELFIRSTAUTH,
                                     {$ENDIF}
                                     {$IFDEF PUMP_ICON_EXT}
                                     {$IFDEF FF_PROMO}
                                      FR_FUELFIRST_AUTH_WIN,
                                      FR_FLOWSTARTFUELFIRST_WIN, FR_FLOWENDFUELFIRST_WIN,
                                     {$ENDIF}
                                      FR_FLOWSTARTFUELFIRST, FR_FLOWENDFUELFIRST,
                                     {$ENDIF}
                                     FR_FLOWSTART, FR_FLOWEND,
                                     FR_STOP]) then
    begin
      if sPumpNo <> '' then
      begin
        SendFuelMessage( pNo, FS_RESETPUMP, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
      end;
    end
    else
      //SendFuelMessage( pNo, PMP_DEAUTH, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
      POSError('Deauthorize Pump '+sPumpNo+ ' to Refresh');
  //20060531...
  end
  else      // Added catch for empty string
  begin
    POSError('Please Select A Pump');
    Exit;
  end;
  //...20060531
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyFUL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyFUL;
begin

  SendFuelMessage( 0, FS_RESETFUEL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCAT
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCAT;
Begin

  SendFuelMessage( 0, FS_RESETCAT, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCT1
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCT1;
var
  pNo :short;
Begin
  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      SendFuelMessage( pNo, FS_SINGLESOFTCATRESET, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);
      SelPumpIcon := nPumpIcons[StrToInt(sPumpNo)];
      SelPumpIcon.Frame := FR_IDLECATOFF;
    end;
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCT2
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCT2;
var
  pNo :short;
Begin
  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      SendFuelMessage( pNo, FS_SINGLEHARDCATRESET, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);
      SelPumpIcon := nPumpIcons[StrToInt(sPumpNo)];
      SelPumpIcon.Frame := FR_IDLECATOFF;
    end;
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCT3
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCT3;
var
  pNo :short;
Begin
  if sPumpNo <> '' then
    begin
      pNo := StrToInt(sPumpNo);
      SendFuelMessage( pNo, FS_SINGLECATONOFF, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP);
    end;
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCDT
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCDT;
var
CCMsg : string;
begin

  CCMsg := BuildTag(TAG_MSGTYPE, IntToStr(CC_RESETSERVER));
  SendCreditMessage(CCMsg);

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.Track2TimerTimer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.Track2TimerTimer(Sender: TObject);
begin
  Track2Timer.Enabled := False;
  EntryBuff := '';
  move(KeyBuff,EntryBuff[0],BuffPtr );
  KeyBuff := '';
  BuffPtr := 0;
  PostMessage(fmPOS.Handle,WM_PREPROCESSKEY,0,0);
//  POSError('Track 2 sent');
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCCR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCCR;
Begin
  fmCardReceipt.Visible := False;
  fmCardReceipt.ShowModal;
  fmCardReceipt.ModalResult := mrOK;
  fmCardReceipt.Visible := False;
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyUSO
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyUSO;
Var
  CodeEntered : Boolean;
  i : short;
  //20070926b
//  AlreadyOn : wordbool;
//  CheckUser : integer;
//  OnTerminal : integer;
  //20070926b
  bResetKeyboard, bReloadSetup : boolean;
  nStartingTillAmount : currency;
Begin
  ClosePole; //20071023d Change message to closed if waiting to log in
  bResetKeyboard := False;
//cwe  bReloadSetup   := False;
  If Security_Active Then
  Begin
    if CurrentUserID > '' then
      LogSignOnOff(False);
    POSDataMod.IBUserQuery.Close;
    StatusBar1.Panels.Items[4].Text := '';
    if not assigned(PPTrans) then
      try
        CloseTables;
      except
        on e: Exception do UpdateExceptLog('ProcessKeyUSO: Cannot close tables: %s', [e.Message]);
      end;
    //20070926b...
//    while true do
    CodeEntered := False;
    while not CodeEntered do
    //...20070926b
    begin
      CurrentUserID   := '';
      CurrentUser     := '';
      fmUser.Visible := False;
//20070926b      CodeEntered := False;
      {We dim the colors in POS }
      Repeat
        If fmUser.ShowModal = mrOK Then
          CodeEntered := True;
        If bPOSForceClose = True then
          exit;
      until CodeEntered;
      //20070926b...  (Moved to UserSignOnOff form)
//      if (PosUser.SelectedUserID = 'XXXX') then CheckUser := SUPPORT_USER_ID
//      else                                      CheckUser  := StrToInt(PosUser.SelectedUserID);
//      try
//        case nFuelInterfaceType of
//          1,2 : AlreadyOn := fmPOS.DCOMFuelProg.CheckUserLogOn(CheckUser, OnTerminal);
//          else
//          AlreadyOn := false;
//        end;
//
//      except
//        { Here we might get an exception once in a while when the Fuelserver }
//        { has already been closed...                                         }
//        AlreadyOn := False;
//      end;
//      if AlreadyOn then
//      begin
//        if OnTerminal = 99 then
//          POSError('Please Wait... Closing In Progress' )
//        else
//          POSError('User Already Signed-On Terminal# ' + IntToStr(OnTerminal) );
//        continue;
//      end
//      else
//        break;
      //...20070926b
    end;
    if ThisTerminalNo <> MasterTerminalNo then
      if SoftwareUpdatePending then
      begin
        ApplySoftwareUpdate;
        fmPOSMsg.Close;
      end;
    if bPOSForceClose then
      exit;
    CurrentUserID   := PosUser.SelectedUserID;
    CurrentUser     := PosUser.SelectedUser;
    StatusBar1.Panels.Items[4].Text := CurrentUser;
    fmUser.ModalResult := mrOK;
    fmUSer.Visible := False;
    if not POSDataMod.IBDB.TestConnected then
      OpenTables(false);
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      Close;SQL.Clear;
      SQL.Add('Select CurShift from Terminal where TerminalNo = ' + IntToStr(ThisTerminalNo));
      Open;
      nShiftNo := FieldByName('CurShift').AsInteger;
      Close;
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;

    if ThisTerminalNo = MasterTerminalNo then
    try
      FFPCPostThread.Resume;
    except
      on E: Exception do
      begin
        UpdateExceptLog('Failed to resume FPC thread after login - restarting - %s: %s', [E.ClassName, E.Message]);
        try
          FFPCPostThread := nil;
          StartFPCThread;
          FFPCPostThread.Resume;
        except
          UpdateExceptLog('Failed to resume FPC thread after restarting - ignoring - %s: %s', [E.ClassName, E.Message]);
        end;
      end;
    end;

    curSale.nTransNo := 0;
    StatusBar1.Panels.Items[0].Text := 'Terminal# ' + IntToStr(ThisTerminalNo) + ' Shift# ' + InttoStr (nShiftNo);
    if nUseStartingTill = STARTINGTILL_ENTER then
    begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Select StartingTill From Totals where (TerminalNo = ' + IntToStr(ThisTerminalNo) +
                ') and (ShiftNo = ' + IntToStr(nShiftNo) + ')');
        Open;
        nStartingTillAmount := FieldByName('StartingTill').AsCurrency;
        Close;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      if nStartingTillAmount = 0 then
      begin
        fmStartingTill.Visible := False;
        fmStartingTill.ShowModal;
        fmStartingTill.ModalResult := mrOK;
        fmStartingTill.Visible := False;
      end;
    end
    else if nUseStartingTill = STARTINGTILL_DEFAULT then
    begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        Close;SQL.Clear;
        SQL.Add('Update Totals set StartingTill = :pStartingTill where (TerminalNo = ' + IntToStr(fmPOS.ThisTerminalNo) +
                ') and (ShiftNo = ' + IntToStr(nShiftNo) + ')');
        ParamByName('pStartingTill').AsCurrency := nStartingTillDefault;
        try
          ExecSQL;
          POSDataMod.IBTransaction.Commit;
        except
          on E : Exception do
          begin
            POSDataMod.IBTransaction.Rollback;
            UpdateExceptLog('Rollback Set Starting Till ' + e.message);
          end;
        end;
        Close;
      end;
    end;
    if bUserPopUpMsg then
    begin
      for i:= 0 to PopUpMsgList.Count - 1 do
      begin
        PopUpMsg := PopUpMsgList.Items[i];
        if PopUpMsg^.MsgType = 3 then
        begin
          if (Length(Trim(PopUpMsg^.MsgUserID)) = 0) or
             (Trim(PopUpMsg^.MsgUserID) = Trim(CurrentUser)) then
            fmPopUpMsg.ShowModal;
        end;
      end;
    end;
    POSDataMod.IBUserQuery.Close;
    if CurrentUserID = 'XXXX' then
    begin
      SkipPassCheck := True;
      bAllowMgrLock := True;
    end
    else
    begin
      if not POSDataMod.IBUserTransaction.InTransaction then
        POSDataMod.IBUserTransaction.StartTransaction;
      POSDataMod.IBUserQuery.parambyname('pUserID').AsString := Trim(CurrentUserID);
      POSDataMod.IBUserQuery.Open;
      bAllowMgrLock := Boolean(POSDataMod.IBUserQuery.FieldByName('AllowMgrLock').AsInteger);
      if (bLeftHanded <> Boolean(POSDataMod.IBUserQuery.FieldByName('LeftHanded').AsInteger)) then
      begin
        bLeftHanded := Boolean(POSDataMod.IBUserQuery.FieldByName('LeftHanded').AsInteger);
        bResetKeyboard := True;
      end;
      SkipPassCheck := False;
      POSDataMod.IBUserQuery.Close;
      if POSDataMod.IBUserTransaction.InTransaction then
        POSDataMod.IBUserTransaction.Commit;
    end;
  end
  else
  begin
    SkipPassCheck := True;
    bAllowMgrLock := True;
  end;
  LogSignOnOff(True);
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select ReloadSetup from Terminal where TerminalNo = ' + IntToStr(ThisTerminalNo) );
    Open;
    bReloadSetup  :=  Boolean(FieldByName('ReloadSetup').AsInteger);
    Close;
    if bReloadSetup then
    begin
      Close;SQL.Clear;
      SQL.Add('Update Terminal Set ReloadSetup = 0 where TerminalNo = ' + IntToStr(ThisTerminalNo) );
      ExecSQL;
    end;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  if bReloadSetup then
  begin
    ClosePorts;
    LoadSetup;
  end;
  if (bResetKeyboard) and (NOT bReloadSetup) then
  begin
    BuildPOSTouchScreen;
  end;
  nCurMenu := 0;
  DisplayMenu(nCurMenu);
  if ThisTerminalNo = MasterTerminalNo then
    bBackupDone := False
  else
    bBackupDone := True;
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select Count(*) RecCount from Totals where (TerminalNo = ' + IntToStr(ThisTerminalNo) +
            ') and (ShiftNo = ' + IntToStr(nShiftNo) + ')');
    Open;
    nTotalCheckCount := FieldByName('RecCount').AsInteger;
    Close;
    if nTotalCheckCount = 0 then
      POSError('The Last EOD or EOS did not Complete!!');
  end;
  if POSDataMod.IBTransaction.InTransaction then
     POSDataMod.IBTransaction.Commit;
  BuildRestrictedDeptList();
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCRL
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCRL;
Var
//cwe  PumpSale_found : Boolean;
//cwe  i              : Integer;
  Msg            : string;
Begin

 { We check if any pumps are not Idle. If not we want them to confirm the download }

  try
    fmPOSErrorMsg.Visible := False;
    If Not(fmPOSErrorMsg.Visible) Then
      begin
        if fmPOSErrorMsg.YesNo('POS Confirm', 'Reload Controller (Enter=Yes, Clear=No)') = mrOk then
          Begin
            Msg  := BuildTag(FSTAG_PUMPNO, '0')  + BuildTag(FSTAG_PUMPACTION, IntToStr(PMP_DOWNLOADFILES) );
            case nFuelInterfaceType of
            1,2 : SendRawFuelMessage(Msg);
            end;
          End
        else
          exit;
      end;
    fmPOSErrorMsg.ModalResult := mrOK;
    fmPOSErrorMsg.Visible := False;
  except
    fmPOSErrorMsg.ModalResult := mrOK;
    sleep(100);
    exit;
  end;

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPFR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPFR;
Begin
  fmFuelReceipt.Visible := False;
  fmFuelReceipt.ShowModal;
  fmFuelReceipt.ModalResult := mrOK;
  fmFuelReceipt.Visible := False;
End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.EmptyReceiptList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.EmptyReceiptList;
var
i : short;
begin

  if ReceiptList.Count > 0 then
  begin
    for i := 0 to ReceiptList.Count - 1 do
    begin
      try
        ReceiptData := ReceiptList.Items[i];
        Dispose(ReceiptData);
      except
      end;
    end;
  end;
  ReceiptList.Clear;
  ReceiptList.Capacity := ReceiptList.Count;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FormMouseDown
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

begin
//  If (ssShift in Shift) and (ssAlt in Shift) and (ssCtrl in Shift) and Not(fmKybdSetup.Visible) then
//    Begin
//       fmKybdSetup.SetupKybd;
//       fmKybdSetup.Show;
//   End;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FuelPriceTimerTimer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.FuelPriceTimerTimer(Sender: TObject);
Var
  f         			: Textfile;
  P1,P2,P3  			: Real;
  T1,T2,T3  			: String;
  TempLine  			: String;
  TempDir  			: string;
  TempDirNullTerm	: Array [0..100] of char;
  i         			: Integer;
//cwe  chrItem   			: char;
  MyHandle         	: Hwnd;
  S                	: String;
  P                	: Array [0..100] of char;
  HostComm 		  	: Hwnd;

begin
	{ We have to check Host Communications is running : }
  If EODExports or FuelPriceImport Then
  	Begin
  		MyHandle := GetWindow (Application.Handle, GW_HWNDFIRST);
  		HostComm := 0;
        i := 0;
  		Repeat
     		GetClassName(MyHandle, P, 100);
     		S := StrPas(P);

     		If (s = 'TfmHComm') Then
     			Begin
        			HostComm := MyHandle;
           		i :=101;
              end;
     		MyHandle := GetWindow (MyHandle, GW_HWNDNEXT);
     		Inc(i);
  		Until i > 100;
			if HostComm = 0 then
        	Begin
                 TempDir := ExtractFileDir(Application.ExeName);
                 StrPCopy(TempDirNullTerm, TempDir);
        	 ShellExecute(Handle,'open','Iriscom.exe','', TempDirNullTerm,SW_SHOWNORMAL);
           End;
     End;

 { We have to check if we received a Fuelprice change from the Host : }
 If Not(FuelPriceImport) Then
   Exit;

  If FileExists(FuelPricePath + '\Gasprice.dat') Then
    Begin
       FuelPriceImport := False;
       Assignfile(f, FuelPricePath + '\Gasprice.dat');
       Reset(f);
       i := 1;
       While ((Not(EOF(f))) and (i <= 3)) do
        Begin
          Readln(f,Templine);
          Case i of
            1 : T1 := Templine;
            2 : T2 := Templine;
            3 : T3 := Templine;
          End;
          Inc(i);
        End;
       Closefile(f);

       fmPOSErrorMsg.Continue('Price changes received from Host !', 'Unleaded: ' + T1 + '   Midgrade:' + T2 + '   Premium:' + T3);
       fmPOSErrorMsg.ModalResult := mrOK;

       { Warning : We assume that Unleaded = GradeNo 1 and Midgrade = 2 and Premium = 3 !! }

       { We have to figure out if we have a price increase or decrease }
       if not POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.StartTransaction;
         with POSDataMod.IBTempQuery do
          begin
            { Unleaded }
            Close; SQL.Clear;
            SQL.Add( 'Select * from Grade order by GradeNo');
            Open; First;
            P1 := FieldByName('CashPrice').AsCurrency;
            Next;
            P2 := FieldByName('CashPrice').AsCurrency;
            Next;
            P3 := FieldByName('CashPrice').AsCurrency;
            Close;
          end;

       { Now we save the new prices in the database... }

         with POSDataMod.IBTempQuery do
          begin
            { Unleaded }
            Close; SQL.Clear;
             SQL.Add( 'Update Grade Set CashPrice = ' + T1 + ' where GradeNo = 1');
            ExecSQL;

            { Midgrade }
            Close; SQL.Clear;
             SQL.Add( 'Update Grade Set CashPrice = ' + T2 + ' where GradeNo = 2');
            ExecSQL;

            { Premium }
            Close; SQL.Clear;
             SQL.Add( 'Update Grade Set CashPrice = ' + T3 + ' where GradeNo = 3');
            ExecSQL;

          end;
       if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
         If (P1 < StrToFloat(T1)) or (P2 < StrToFloat(T2)) or (P3 < StrToFloat(T3)) Then
          Begin
            { Price Increase ! We change the sign first and the pumps after 2 min. }
            { We send the new Fuel prices to the sign... }
            PriceSgnItemNo := 0;           {Items on the PriceSgn are zero based 0=firstitem}
            PriceSgnChg := false;
            PriceIncrease := True;
            SendPrice('0',Trim(T1));
            FuelPriceTimer.Interval := PriceChgTime;
            FuelPriceTimer.Tag := 1;      {Set for Timeout check}
          End
         Else
          Begin
            { Price Decrease ! We change the pumps first and the sign after 2 min. }
            { We send the new Fuel prices to the pump... }
            PriceSgnItemNo := 0;           {Items on the PriceSgn are zero based 0=firstitem}
            PriceSgnChg := false;
            PriceIncrease := False;
            ProcessKeySP1;                 {Send Fuel Pump prices}
            FuelPriceTimer.Tag := 1;    {Set for Timeout check}
            FuelPriceTimer.Interval := MaxTime;
          End;
       Deletefile(FuelPricePath + '\Gasprice.dat');
       FuelPriceImport := True;
    End { of if Pricechange file exists... }
  Else if FuelPriceTimer.Tag <> 0 Then
    Begin
      { We are in progress of changing the prices... }
      If FuelPriceTimer.Tag < 100 Then
       Begin
         if (not(PriceIncrease) and (PriceSgnItemNo = 0) and (FuelPriceTimer.Tag = 1)) then
           Begin
             if not POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.StartTransaction;
             with POSDataMod.IBTempQuery do
               Begin
                 Close; SQL.Clear;
                 SQL.Add( 'Select * from Grade where GradeNo = ' + IntToStr(PriceSgnItemNo + 1)[1]);
                 Open;
                 T1 := FieldByName('CashPrice').AsString;
                 SendPrice('0',Trim(T1));
                 Close;
               End;
             if POSDataMod.IBTransaction.InTransaction then
              POSDataMod.IBTransaction.Commit;
             FuelPriceTimer.Interval := PriceChgTime;
             FuelPriceTimer.Tag := FuelPriceTimer.Tag +1;
           End
         Else If ((PriceSgnChg) or (PriceSgnItemNo > MaxPriceItems)) Then { We are done sending prices}
           Begin
             FuelPriceTimer.Tag := 0;
             MessageBeep(1);
             fmPOS.POSError('Price Sign has sent all New Prices.');
             FuelPriceTimer.Interval := PriceChgTime;
             if PriceIncrease then
               Begin
                 ProcessKeySP1;       {Send Fuel Pump prices}
               End;
           End
         Else if ((Not(PriceSgnChg)) and (FuelPriceTimer.Tag >= MaxPriceWait))  Then
              Begin
                if (PriceSgnItemNo > MaxPriceItems) then
                  Begin
                    PriceSgnChg := true;
                  End
                Else if (FuelPriceTimer.Tag = MaxPriceWait) Then
                  Begin
                    RemoteReset(inttostr(PriceSgnItemNo)[1]);
                    FuelPriceTimer.Tag := FuelPriceTimer.Tag +1;
                  End  {End (FuelPriceTimer.Tag = MaxPriceWait)}
                Else
                  Begin
                    if (PriceSgnItemNo >= MaxPriceItems) then
                       Begin
                         MessageBeep(1);
                         fmPOS.POSError('Price Sign has Timed out on ItemNo = ' + inttostr(PriceSgnItemNo+1));
                         FuelPriceTimer.Enabled := False;
                         FuelPriceTimer.Enabled := True;
                         PriceSgnChg := true;
                         FuelPriceTimer.Tag := MaxPriceWait + 1;
                       End
                    Else
                      Begin
                       MessageBeep(1);
                       fmPOS.POSError('Price Sign has Timed out on ItemNo = ' + inttostr(PriceSgnItemNo+1));
                       FuelPriceTimer.Enabled := False;
                       FuelPriceTimer.Enabled := True;
                       if not POSDataMod.IBTransaction.InTransaction then
                        POSDataMod.IBTransaction.StartTransaction;
                       with POSDataMod.IBTempQuery do
                        Begin
                         inc(PriceSgnItemNo);
                         Close; SQL.Clear;
                         SQL.Add( 'Select * from Grade where GradeNo = ' + IntToStr(PriceSgnItemNo + 1)[1]);
                         Open;
                         T1 := FieldByName('CashPrice').AsString;
                         FuelPriceTimer.Tag := 1;
                         //SendPrice(inttostr(PriceSgnItemNo)[1], Trim(T1));
                         SendPrice('0',Trim(T1));
                         Close;
                        End; {End TempQuery }
                       if POSDataMod.IBTransaction.InTransaction then
                          POSDataMod.IBTransaction.Commit;
                      End; {End Else PriceSgnItemNo = MaxPriceItems}
                  End; {End Else PriceSgnItemNo >= MaxPriceItems}
              End {End Timeout error}
         Else if (Not(PriceSgn.flgInMotion)) then
              Begin
                if (PriceSgnItemNo >= MaxPriceItems) then
                  Begin
                    PriceSgnChg := true;
                  End
                Else
                  Begin
                    if not POSDataMod.IBTransaction.InTransaction then
                      POSDataMod.IBTransaction.StartTransaction;
                    with POSDataMod.IBTempQuery do
                    Begin
                      inc(PriceSgnItemNo);
                      Close; SQL.Clear;
                      SQL.Add( 'Select * from Grade where GradeNo = ' + IntToStr(PriceSgnItemNo + 1)[1]);
                      Open;
                      T1 := FieldByName('CashPrice').AsString;
                      SendPrice('0',Trim(T1));
                      FuelPriceTimer.Tag := 1;
                      Close;
                    End; {End TempQuery}
                    if POSDataMod.IBTransaction.InTransaction then
                      POSDataMod.IBTransaction.Commit;
                  End; {End Else PriceSgnItemNo >= MaxPriceItems}
              End{End flgInMotion check}
         Else
            Begin
              FuelPriceTimer.Tag := FuelPriceTimer.Tag +1;
              RptPositions('0');
            End; {End Else - (Not(PriceSgn.flgInMotion))}
       End; { End Price Change }
    End;  { of if FuelPriceTimer.Tag <> 0 }
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PriceSignPortTriggerAvail
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CP: TObject; Count: Word
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.PriceSignPortTriggerAvail(CP: TObject; Count: Word);
begin
  PriceSgn.PriceSignPortTriggerAvail(CP, Count);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FuelButtonDragOver
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.FuelButtonDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  Accept := Source is TPumpxIcon;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FuelButtonDragDrop
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender, Source: TObject; X, Y: Integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.FuelButtonDragDrop(Sender, Source: TObject; X, Y: Integer);
begin

  if (Sender is TPumpxIcon) and (Source is TPumpxIcon) then
    if TPumpxIcon(Sender).PumpNo <> TPumpxIcon(Source).PumpNo then
      SendFuelMessage(TPumpxIcon(Source).PumpNo, PMP_MOVEPREPAY, NOAMOUNT, NOSALEID, NOTRANSNO, TPumpxIcon(Sender).PumpNo);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FuelButtonMouseDown
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.FuelButtonMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin

  if (ssRight in Shift) and (ssAlt in SHift) then
    begin
      PostMessage(fmPOS.Handle,WM_ShowPumpInfo,0,TPumpxIcon(Sender).PumpNo);
    end;

  if TPumpxIcon(Sender).Sale1Type = FUELSALETYPE_PREPAYINSIDE then
    TPumpxIcon(Sender).BeginDrag(False);

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FuelButtonLongPress
  Author:
  Date:      2010-12-01
  Arguments: Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.FuelButtonLongPress(Sender: TObject);
var
  i : integer;
begin
  with sender as TPumpXIcon do
    if PumpLockStatus <> plsDisabled then
    begin
      PumpPopupMenu.Tag := longint(sender);
      for i := 0 to pred(PumpPopupMenu.Items.Count) do
        case PumpPopupMenu.Items[i].GroupIndex of
          0: PumpPopupMenu.Items[i].Enabled := (Self.PumpLockMgr.PumpStatus[PumpNo] > plsNoRemComms);
          1: PumpPopupMenu.Items[i].Enabled := bAllowMgrLock;
        end;
      PumpPopupMenu.Popup(left + width, top);
    end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ShowPumpInfo
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg:TMessage
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ShowPumpInfo(var Msg:TMessage);
//cwe  var
//cwe  InfoPump : TPumpxIcon;
begin

  fmPumpInfo.PumpNo := Msg.LParam;
  fmPumpInfo.Show;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PopUpMsgTimerTimer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.PopUpMsgTimerTimer(Sender: TObject);
var
i, x : short;
begin

  (*if (fmPOSErrorMsg.Visible = True) or
    (fmPOSMsg.Visible = True) or
    (fmFuelSelect.Visible = True) or
    (fmPLUSalesReport.Visible = True) or
    (fmValidAge.Visible = True) or
    (fmEnterAge.Visible = True) or
    (fmADSCCForm.Visible = True) or
    (fmNBSCCForm.Visible = True) or
    (fmCardReceipt.Visible = True) or
    (fmFuelReceipt.Visible = True) or
    (fmPopUpMsg.Visible = True) or
    (fmPriceOverride.Visible = true) or
    (fmPriceCheck.Visible = true) or
    (fmUser.Visible = True) then*)
  if not (fmPOS.Handle = GetActiveWindow) then
    exit;

  if (CurSaleList.Count = 0) then
  begin
    if bPopUpMsg then
    begin
      for i:= 0 to PopUpMsgList.Count - 1 do
      begin
        PopUpMsg := PopUpMsgList.Items[i];
        if PopUpMsg^.MsgType = 4 then
        begin
          if PopUpMsg^.MsgTime <= Time() then
          begin
            fmPopUpMsg.ShowModal;
            Dispose(PopUpMsg);
            PopUpMsgList.Delete(i);
            PopUpMsgList.Pack;
            PopUpMsgList.Capacity := PopUpMsgList.Count;
            bPopUpMsg := False;
            for x := 0 to PopUpMsgList.Count - 1 do
            begin
              PopUpMsg := PopUpMsgList.Items[x];
              if PopUpMsg^.MsgType = 4 then
              begin
                bPopUpMsg := True;
                break;
              end;
            end;
            break;
          end
        end;
      end;
    end;
  end;
  if NOT bPopUpMsg then
    PopUpMsgTimer.Enabled := False;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.InitPopUpMsgList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.InitPopUpMsgList();
var
//cwe  ndx : integer;
DayMatch : boolean;
ShowMsgTime : TTime;
MsgIncrement : double;
ndx : short;
begin
  if not POSDataMod.IBDb.TestConnected then
    fmPOS.OpenTables(False);
  bEODPopUpMsg := False;
  bEOSPopUpMsg := False;
  bUserPopUpMsg := False;
  bPopUpMsg    := False;
  DayMatch := False;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('SELECT * FROM POPUPMSG');
    Open;
    First;
    while not EOF do
    begin
      if FieldByName('MsgType').AsInteger = 1 then
      begin
        InitPopUpMsgRecord;
        PopUpMsg^.MsgType   := FieldByName('MsgType').AsInteger;
        PopUpMsg^.MsgTime   := 0;
        PopUpMsg^.MsgHeader := FieldByName('MsgHeader').AsString;
        for ndx := 1 to 10 do
        begin
          PopUpMsg^.MsgLine[ndx] := FieldByName('MsgLine'+ IntToStr(ndx)).AsString;
        end;
        PopUpMsgList.Capacity := PopUpMsgList.Count;
        PopUpMsgList.Add(PopUpMsg);
        bEODPopUpMsg := True;
      end
      else if FieldByName('MsgType').AsInteger = 2 then
      begin
        InitPopUpMsgRecord;
        PopUpMsg^.MsgType   := FieldByName('MsgType').AsInteger;
        PopUpMsg^.MsgTime   := 0;
        PopUpMsg^.MsgHeader := FieldByName('MsgHeader').AsString;
        for ndx := 1 to 10 do
        begin
          PopUpMsg^.MsgLine[ndx] := FieldByName('MsgLine'+ IntToStr(ndx)).AsString;
        end;
        PopUpMsgList.Capacity := PopUpMsgList.Count;
        PopUpMsgList.Add(PopUpMsg);
        bEOSPopUpMsg := True;
      end
      else if FieldByName('MsgType').AsInteger = 3 then
      begin
        InitPopUpMsgRecord;
        PopUpMsg^.MsgType   := FieldByName('MsgType').AsInteger;
        PopUpMsg^.MsgUserID := FieldByName('MsgUserID').AsString;
        PopUpMsg^.MsgTime   := 0;
        PopUpMsg^.MsgHeader := FieldByName('MsgHeader').AsString;
        for ndx := 1 to 10 do
        begin
          PopUpMsg^.MsgLine[ndx] := FieldByName('MsgLine'+ IntToStr(ndx)).AsString;
        end;
        PopUpMsgList.Capacity := PopUpMsgList.Count;
        PopUpMsgList.Add(PopUpMsg);
        bUserPopUpMsg := True;
      end
      else if FieldByName('MsgType').AsInteger = 4 then
      begin
        case DayOfWeek(Now()) of
          1 :  DayMatch := Boolean(FieldByName('MsgSunday').AsInteger);
          2 :  DayMatch := Boolean(FieldByName('MsgMonday').AsInteger);
          3 :  DayMatch := Boolean(FieldByName('MsgTuesday').AsInteger);
          4 :  DayMatch := Boolean(FieldByName('MsgWednesday').AsInteger);
          5 :  DayMatch := Boolean(FieldByName('MsgThursday').AsInteger);
          6 :  DayMatch := Boolean(FieldByName('MsgFriday').AsInteger);
          7 :  DayMatch := Boolean(FieldByName('MsgSaturday').AsInteger);
        end;

        if DayMatch then
        begin
          if FieldByName('MsgTimeType').AsInteger = 1 then //fixed time message
          begin
            if frac(FieldByName('MsgStartTime').AsDateTime) > Time() then
            begin
              InitPopUpMsgRecord;
              PopUpMsg^.MsgType   := FieldByName('MsgType').AsInteger;
              PopUpMsg^.MsgTime   := Frac(FieldByName('MsgStartTime').AsDateTime);
              PopUpMsg^.MsgHeader := FieldByName('MsgHeader').AsString;
              for ndx := 1 to 10 do
              begin
                PopUpMsg^.MsgLine[ndx] := FieldByName('MsgLine'+ IntToStr(ndx)).AsString;
              end;
              PopUpMsgList.Capacity := PopUpMsgList.Count;
              PopUpMsgList.Add(PopUpMsg);
              bPopUpMsg := True;
            end;
          end
          else if FieldByName('MsgTimeType').AsInteger = 2 then //recurring message
          begin
            if frac(FieldByName('MsgStopTime').AsDateTime) > Time() then
            begin
              ShowMsgTime := Frac(FieldByName('MsgStartTime').AsDateTime);
              MsgIncrement := ((FieldByName('MsgInterval').AsInteger ) / 1440);
              while ShowMsgTime <= Frac(FieldByName('MsgStopTime').AsDateTime) do
              begin
                if ShowMsgTime >= Time() then
                begin
                  InitPopUpMsgRecord;
                  PopUpMsg^.MsgType   := FieldByName('MsgType').AsInteger;
                  PopUpMsg^.MsgTime   := ShowMsgTime;
                  PopUpMsg^.MsgHeader := FieldByName('MsgHeader').AsString;
                  for ndx := 1 to 10 do
                  begin
                    PopUpMsg^.MsgLine[ndx] := FieldByName('MsgLine'+ IntToStr(ndx)).AsString;
                  end;
                  PopUpMsgList.Capacity := PopUpMsgList.Count;
                  PopUpMsgList.Add(PopUpMsg);
                  bPopUpMsg := True;
                end;
                ShowMsgTime := ShowMsgTime + MsgIncrement;
              end;
            end;
          end;
        end;
      end;
      Next;
    end;
    Close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  if bPopUpMsg then
  begin
    PopUpMsgTimer.Enabled := False;
    PopUpMsgTimer.Interval := 10000;
    PopUpMsgTimer.Enabled := True;
  end;


end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.InitPopUpMsgRecord
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.InitPopUpMsgRecord();
var
ndx : short;
begin

  New(PopUpMsg);
  PopUpMsg^.MsgType := 0;
  PopUpMsg^.MsgTime := 0;
  PopUpMsg^.MsgHeader := '';
  for ndx := 1 to 10 do
   PopUpMsg^.MsgLine[ndx] := '';

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.InitTaxList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.InitTaxList();
var
  curtax, tmptax : pSalesTax;
  ndx : integer;
  jcc : integer;
begin
  //20041215...
  EnterCriticalSection(CSTaxList);  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  try // PROGRAMMING WARNING:  Do not exit this try block without leaving critical section.
  //...20041215 (following block indented as part of change)
    // entry with tax no = 0 is used for non-tax sales
    New(curtax);
    InitTaxRecord(curtax);
    CurSalesTaxList.Capacity := CurSalesTaxList.Count;
    CurSalesTaxList.Add(curtax);
    //Gift
    for jcc := 0 to NUM_CREDIT_CLIENTS - 1 do
    begin
      New(tmptax);
      Move(curtax^, tmptax^, sizeof(TSalesTax));
      CreditClient[jcc].RestrictSalesTaxList.Capacity := CreditClient[jcc].RestrictSalesTaxList.Count;
      CreditClient[jcc].RestrictSalesTaxList.Add(tmptax);
    end;
    //Gift
    with PosDataMod.IBTempQuery do
    begin
      if not Transaction.InTransaction then
        Transaction.StartTransaction;
      Close;SQL.Clear;
      SQL.Add('SELECT * FROM TAX ORDER BY TAXNO ');
      Open;
      First;
      while not EOF do
      begin
        New(curtax);
        InitTaxRecord(curtax);

        curtax^.TaxNo       := FieldByName('TaxNo').AsInteger;
        curtax^.TaxName     := FieldByName('Name').AsString;
        curtax^.TaxType     := FieldByName('TaxType').AsInteger;
        curtax^.FirstPenny  := FieldByName('FirstCent').AsCurrency;
        curtax^.SalesTax    := (FieldByName('SalesTax').AsInteger = 1);

        if curtax^.TaxType = TAX_TYPE_QTY then  // flat tax per item
        begin
          curtax^.TaxRate := FieldByName('Rate').AsCurrency;
        end
        else if curtax^.TaxType = TAX_TYPE_RATE then  //rate
        begin
          curtax^.TaxRate := (FieldByName('Rate').AsCurrency / 100);
        end
        else  //table
        with POSDataMod.IBTaxTableQuery do
        begin
          Close;SQL.Clear;
          SQL.Add('SELECT * FROM TAXTABLE ');
          SQL.Add('WHERE TAXNO = :pTaxNo ORDER BY SEQNO');
          SQL.Add('ORDER BY SEQNO ');
          ParamByName('pTaxNo').AsInteger := curtax^.TaxNo;
          Open;
          First;
          while NOT EOF do
          begin
            ndx := FieldByName('SeqNo').AsInteger;
            curtax^.Increment[ndx]   := (FieldByName('Increment').AsInteger / 100);
            curtax^.StepType[ndx]    := FieldByName('RecType').AsInteger;
            curtax^.RepeatCount[ndx] := FieldByName('RefNo').AsInteger;
            curtax^.CurCount[ndx]    := FieldByName('RefNo').AsInteger;
            Next;
          end;
          Close;
        end;
        CurSalesTaxList.Capacity := CurSalesTaxList.Count;
        CurSalesTaxList.Add(curtax);
        //Gift
        for jcc := 0 to NUM_CREDIT_CLIENTS - 1 do
        begin
          New(tmptax);
          Move(curtax^, tmptax^, sizeof(TSalesTax));
          CreditClient[jcc].RestrictSalesTaxList.Capacity := CreditClient[jcc].RestrictSalesTaxList.Count;
          CreditClient[jcc].RestrictSalesTaxList.Add(tmptax);
        end;
        //Gift
        Next;
      end;
      Close;
      Transaction.Commit;
    end;
    for ndx := 0 to CurSalesTaxList.Count - 1 do
    begin
      curtax := CurSalesTaxList.Items[ndx];
      New(PostSalesTax);
      PostSalesTax^.TaxNo      := curtax^.TaxNo;
      PostSalesTax^.TaxName    := curtax^.TaxName;
      PostSalesTax^.Taxable    := 0;
      PostSalesTax^.TaxQty     := 0;
      PostSalesTax^.TaxCharged := 0;
      //20040908...
      PostSalesTax^.FSTaxExemptSales  := curtax^.FSTaxExemptSales;
      PostSalesTax^.FSTaxExemptAmount := curtax^.FSTaxExemptAmount;
      //...20040908
      PostSalesTaxList.Capacity := PostSalesTaxList.Count;
      PostSalesTaxList.Add(PostSalesTax);

      New(SavSalesTax);
      SavSalesTax^.TaxNo      := curtax^.TaxNo;
      SavSalesTax^.TaxName    := curtax^.TaxName;
      SavSalesTax^.Taxable    := 0;
      SavSalesTax^.TaxQty     := 0;
      SavSalesTax^.TaxCharged := 0;
      //20040908...
      SavSalesTax^.FSTaxExemptSales  := curtax^.FSTaxExemptSales;
      SavSalesTax^.FSTaxExemptAmount := curtax^.FSTaxExemptAmount;
      //...20040908
      SavSalesTaxList.Capacity := SavSalesTaxList.Count;
      SavSalesTaxList.Add(SavSalesTax);

    end;
  //20041215... (previous block indented as part of change)
  except
  end; // try/except
  LeaveCriticalSection(CSTaxList);  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  //...20041215
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.InitTaxRecord
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.InitTaxRecord(cst : pSalesTax);
var
ndx : integer;
begin
   cst^.TaxNo       := 0;
   cst^.TaxName     := '';
   cst^.TaxType     := 0;
   cst^.TaxRate     := 0;
   cst^.Taxable     := 0;
   cst^.TaxQty      := 0;
   cst^.TaxCharged  := 0;
   cst^.FirstPenny  := 0;
   //20040908...
   cst^.FSTaxExemptSales := 0.0;
   cst^.FSTaxExemptAmount := 0.0;
   //...20040908
   for ndx := 1 to 50 do
   begin
     cst^.Increment[ndx]   := 0;
     cst^.RepeatCount[ndx] := 0;
     cst^.CurCount[ndx]    := 0;
     cst^.StepType[ndx]    := 0;
   end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CreateKybdQuery
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: KybdNdx, MenuNo : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.CreateKybdQuery(KybdNdx, MenuNo : short );
var
//cwe...
//ndx, KybdConfig, AltNo : integer;
  KybdConfig, AltNo : integer;
//...cwe
begin
    KybdConfig := Setup.KybdSetup;
    AltNo := 0;
    case KybdConfig of
    1 :     //System
      begin
        AltNo := 0;
      end;
    2 :     //Terminal
      begin
        AltNo := ThisTerminalNo;
      end;
    3 :     // Shift
      begin
        AltNo := nShiftNo;
      end;
    4 :     //Terminal/Shift
      begin
        AltNo := (ThisTerminalNo * 10) + nShiftNo;
      end;
    5 :     //Cashier
      begin
      end;
    end;


  if not POSDataMod.IBKybdTransaction.InTransaction then
    POSDataMod.IBKybdTransaction.StartTransaction;
  with POSDataMod.IBKybdQuery do
  begin
    Close;SQL.Clear;
    if KybdNdx = 0 then
      SQL.Add('Select * from TouchKybd Where AltNo = ' + IntToStr(AltNo) + ' AND MenuNo = ' + IntToStr(MenuNo) )
    else
      SQL.Add('Select * from TouchKybd Where AltNo = 0 AND MenuNo = ' + IntToStr(MenuNo) );
    Open;
    First;
    KybdArrayNdx := 0;
    while NOT EOF do
    begin
      KybdArray[KybdNdx,KybdArrayNdx].AltNo              := FieldByName('AltNo').AsInteger;
      KybdArray[KybdNdx,KybdArrayNdx].MenuNo             := FieldByName('MenuNo').AsInteger;
      KybdArray[KybdNdx,KybdArrayNdx].KeyCode            := FieldByName('Code').AsString;
      KybdArray[KybdNdx,KybdArrayNdx].KeyType            := FieldByName('RecType').AsString;
      KybdArray[KybdNdx,KybdArrayNdx].KeyVal             := FieldByName('KeyVal').AsString;
      KybdArray[KybdNdx,KybdArrayNdx].Preset             := FieldByName('Preset').AsString;
      KybdArray[KybdNdx,KybdArrayNdx].MgrLock            := Boolean(FieldByName('MgrLock').AsInteger);

      KybdArray[KybdNdx,KybdArrayNdx].BtnShape           := FieldByName('BtnShape').AsInteger;
      KybdArray[KybdNdx,KybdArrayNdx].BtnColor           := UpperCase(FieldByName('BtnColor').AsString);
      if KybdArray[KybdNdx,KybdArrayNdx].BtnColor = 'BLUE' then
        KybdArray[KybdNdx,KybdArrayNdx].BtnColorNo := 1
      else if KybdArray[KybdNdx,KybdArrayNdx].BtnColor = 'GREEN' then
        KybdArray[KybdNdx,KybdArrayNdx].BtnColorNo := 2
      else if KybdArray[KybdNdx,KybdArrayNdx].BtnColor = 'RED' then
        KybdArray[KybdNdx,KybdArrayNdx].BtnColorNo := 3
      else if KybdArray[KybdNdx,KybdArrayNdx].BtnColor = 'WHITE' then
        KybdArray[KybdNdx,KybdArrayNdx].BtnColorNo := 4
      else if KybdArray[KybdNdx,KybdArrayNdx].BtnColor = 'MAGENTA' then
        KybdArray[KybdNdx,KybdArrayNdx].BtnColorNo := 5
      else if KybdArray[KybdNdx,KybdArrayNdx].BtnColor = 'CYAN' then
        KybdArray[KybdNdx,KybdArrayNdx].BtnColorNo := 6
      else if KybdArray[KybdNdx,KybdArrayNdx].BtnColor = 'YELLOW' then
        KybdArray[KybdNdx,KybdArrayNdx].BtnColorNo := 7 ;

      if KybdArray[KybdNdx, KybdArrayNdx].BtnShape = 1 then
        Inc(KybdArray[KybdNdx,KybdArrayNdx].BtnColorNo,7);

      KybdArray[KybdNdx,KybdArrayNdx].BtnFont            := FieldByName('BtnFont').AsString;
      KybdArray[KybdNdx,KybdArrayNdx].BtnFontColor       := FieldByName('BtnFontColor').AsString;
      KybdArray[KybdNdx,KybdArrayNdx].BtnFontColorNo     := SetPOSButtonFontColor( KybdNdx, KybdArrayNdx );

      KybdArray[KybdNdx,KybdArrayNdx].BtnFontSize        := FieldByName('BtnFontSize').AsInteger;
      if bAutoFont then
        KybdArray[KybdNdx,KybdArrayNdx].BtnFontSize := Round(KybdArray[KybdNdx,KybdArrayNdx].BtnFontSize * 0.75);
      KybdArray[KybdNdx,KybdArrayNdx].BtnFontBold        := FieldByName('BtnFontBold').AsInteger;
      KybdArray[KybdNdx,KybdArrayNdx].BtnLabel           := FieldByName('BtnLabel').AsString;
      KybdArray[KybdNdx,KybdArrayNdx].KeyCaption         := NameTheKey(KybdNdx, KybdArrayNdx );

      if ((KybdNdx > 0) and (Length(Trim(KybdArray[KybdNdx,KybdArrayNdx].KeyCaption)) = 0)) or
            (copy(KybdArray[KybdNdx,KybdArrayNdx].KeyType,1,3) = 'NUS') then
            KybdArray[KybdNdx,KybdArrayNdx].BtnVisible := False
      else
        KybdArray[KybdNdx,KybdArrayNdx].BtnVisible := True;

      Inc(KybdArrayNdx);
      Next;
    end;
    Close;
  end;
  if POSDataMod.IBKybdTransaction.InTransaction then
    POSDataMod.IBKybdTransaction.Commit;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CreateModifierKybdQuery
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: KybdNdx, MenuNo : short
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.CreateModifierKybdQuery(KybdNdx, MenuNo : short );
var
  ndx : Integer;
begin

  for Ndx := 0 to (MaxKeyNo -1) do
  begin
    KybdArray[KybdNdx,Ndx].AltNo              := 0;
    KybdArray[KybdNdx,Ndx].MenuNo             := MenuNo;
    KybdArray[KybdNdx,Ndx].KeyCode            := POSButtons[Ndx + 1 ].KeyCode;
    KybdArray[KybdNdx,Ndx].KeyType            := '';
    KybdArray[KybdNdx,Ndx].KeyVal             := '';
    KybdArray[KybdNdx,Ndx].Preset             := '';
    KybdArray[KybdNdx,Ndx].MgrLock            := False;
    KybdArray[KybdNdx,Ndx].BtnShape           := 1;
    KybdArray[KybdNdx,Ndx].BtnColor           := 'YELLOW';
    if KybdArray[KybdNdx,Ndx].BtnColor = 'BLUE' then
      KybdArray[KybdNdx,Ndx].BtnColorNo := 1
        else if KybdArray[KybdNdx,Ndx].BtnColor = 'GREEN' then
          KybdArray[KybdNdx,Ndx].BtnColorNo := 2
        else if KybdArray[KybdNdx,Ndx].BtnColor = 'RED' then
          KybdArray[KybdNdx,Ndx].BtnColorNo := 3
        else if KybdArray[KybdNdx,Ndx].BtnColor = 'WHITE' then
          KybdArray[KybdNdx,Ndx].BtnColorNo := 4
        else if KybdArray[KybdNdx,Ndx].BtnColor = 'MAGENTA' then
          KybdArray[KybdNdx,Ndx].BtnColorNo := 5
        else if KybdArray[KybdNdx,Ndx].BtnColor = 'CYAN' then
          KybdArray[KybdNdx,Ndx].BtnColorNo := 6
        else if KybdArray[KybdNdx,Ndx].BtnColor = 'YELLOW' then
          KybdArray[KybdNdx,Ndx].BtnColorNo := 7 ;

        if KybdArray[KybdNdx, Ndx].BtnShape = 1 then
          Inc(KybdArray[KybdNdx,Ndx].BtnColorNo,7);

        KybdArray[KybdNdx,Ndx].BtnFont            := 'Arial';
        KybdArray[KybdNdx,Ndx].BtnFontColor       := 'clBlack';
        KybdArray[KybdNdx,Ndx].BtnFontColorNo     := SetPOSButtonFontColor( KybdNdx, Ndx );

        KybdArray[KybdNdx,Ndx].BtnFontSize        := 10;
        KybdArray[KybdNdx,Ndx].BtnFontBold        := 0;
        KybdArray[KybdNdx,Ndx].BtnLabel           := '';
        KybdArray[KybdNdx,Ndx].KeyCaption         := '';
        KybdArray[KybdNdx,Ndx].BtnVisible := False;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisplayTouchKeys
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: KybdNdx, BtnNdx : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.DisplayTouchKeys(KybdNdx, BtnNdx : short );
var
  ndx : Byte;
begin
  for Ndx := 0 to (MaxKeyNo -1) do
  begin
    if KybdArray[KybdNdx, Ndx].KeyCode = POSButtons[BtnNdx].KeyCode then
      break;
  end;

  POSButtons[BtnNdx].KeyType     := Copy((KybdArray[KybdNdx, Ndx].KeyType),1,3);
  POSButtons[BtnNdx].KeyVal      := KybdArray[KybdNdx, Ndx].KeyVal;
  POSButtons[BtnNdx].KeyPreset   := KybdArray[KybdNdx, Ndx].Preset;
  POSButtons[BtnNdx].Caption     := KybdArray[KybdNdx, Ndx].KeyCaption;
  POSButtons[BtnNdx].MgrLock     := KybdArray[KybdNdx, Ndx].MgrLock;


  if not (bFuelSystem and (BtnNdx <= 3)) then
    POSButtons[BtnNdx].Frame := KybdArray[KybdNdx, Ndx].BtnColorNo;

  POSButtons[BtnNdx].Transparent := False;
  POSButtons[BtnNdx].Font.Name := KybdArray[KybdNdx, Ndx].BtnFont;
  POSButtons[BtnNdx].Font.Size := KybdArray[KybdNdx, Ndx].BtnFontSize;
  POSButtons[BtnNdx].Font.Color := KybdArray[KybdNdx, Ndx].BtnFontColorNo;

  if Boolean(KybdArray[KybdNdx, Ndx].BtnFontBold) = True then
    POSButtons[BtnNdx].Font.Style := [fsBold]
  else
    POSButtons[BtnNdx].Font.Style := [];

  POSButtons[BtnNdx].Visible := KybdArray[KybdNdx, Ndx].BtnVisible;


end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.OpenTables
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Verbose : boolean
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.OpenTables(Verbose : boolean);
begin
  try  //20070925a
    if POSDataMod.IBDB.TestConnected = false then
      POSDataMod.IBDB.Connected   := True;
    if Verbose then fmPOSMsg.ShowMsg('', 'System Setup');
    if Verbose then fmPOSMsg.ShowMsg('', 'Terminal Setup');
  //20070925a...
  except
    fmPOS.POSError('Problem reconnecting to database - Restart Latitude');
    bPOSForceClose := true;
    fmPOS.Close;
  end;
  //...20070925a
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CloseTables
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.CloseTables;
begin
  UpdateZLog('TfmPOS.CloseTables: Terminating FPCPostThread');
  try
    if assigned(FFPCPostThread) then
      FFPCPostThread.Terminate;
  except
    on E: Exception do
      UpdateExceptLog('TfmPOS.CloseTables: Failed to terminate FPC thread: %s - %s', [E.ClassName, E.Message]);
  end;
  try
    if assigned(FFPCPostThread) then
      FFPCPostThread.Destroy;
  except
    on E: Exception do
      UpdateExceptLog('TfmPOS.CloseTables: Failed to destroy FPC thread: %s - %s', [E.ClassName, E.Message]);
  end;
  FFPCPostThread := nil;

  with POSDataMod do
  begin
    IBFuelPriceChangeQuery.Close;
    IBTaxTableQuery.Close;
    IBFuelTranQuery.Close;
    IBCCBatchQuery.Close;
    IBUserQuery.Close;
    IBActionQuery.Close;
    IBReportQuery.Close;
    IBReportQuery2.Close;
    IBPDIQuery.Close;
    IBTempQry1.Close;
    IBTempQuery.Close;
    IBTempQuery2.Close;
    IBEODQuery.Close;
    IBShiftQuery.Close;
    IBRestrictionQuery.Close;
    IBGradeQuery.Close;
    IBPrintQuery.Close;
    IBSetupQuery.Close;
    IBReceiptQuery.Close;
    IBModifierQuery.Close;
    IBPLUQuery.Close;
    IBPLUModQuery.Close;
    IBDeptQuery.Close;
    IBBankFuncQuery.Close;
    IBDiscQuery.Close;
    IBTotalsQuery.Close;
    IBNFPLUQuery.Close;
    IBPumpDefQuery.Close;
    IBMediaQuery.Close;
  end;
  POSDataMod.IBDB.Connected   := False;

end;

procedure TfmPOS.StartFPCThread();
begin
  try
    FFPCPostThread := TFPCPostThread.Create(True, StrToInt(Setup.NUMBER));
    FFPCPostThread.FreeOnTerminate := True;
    FFPCPostThread.Priority := tpLowest;
  except on E: Exception do
    begin
      UpdateExceptLog('Problem spawning HTTPThread: ' + E.Message);
      DumpTraceback(E);
      raise;
    end;
  end;
end;

procedure TfmPOS.InitActivationDataForSaleItem(const qActivationProductType : pActivationProductType);
begin
  // If processing PLU for an activation product just swiped, then clear barcode scan prompt.
  if ( fmPOSErrorMsg.Tag = POS_ERROR_MSG_TAG_CARD_ACTIVATION) then
  begin
    ClearCardActivationPrompt();
  end;
  // Only the first UPC processed after swipe of track data for an activation product is accepted.
  if (qActivationProductType^.bNextScanForProduct) then
  begin
    qActivationProductType^.bNextScanForProduct := False;
    qActivationProductType^.bThisScanForProduct := True;
  end
  else
  begin
    ClearActivationProductData(qActivationProductType);
  end;
end;

procedure TfmPOS.CheckItemForActivation(const qSalesData : pSalesData;
                                        const qActivationProductType : pActivationProductType);
var
  sd : pSalesData;
begin
  // Check to see if item needs to be activated.
  if (qSalesData <> nil) then
  begin
    if (qSalesData^.ActivationState in [asWaitBalance, asActivationNeeded]) then
    begin
      StrPCopy(qSalesData^.GCMSRData, Copy(qActivationProductType^.ActivationMSR, 1, SIZE_MSR_DATA-1));
      qSalesData^.CCCardType := qActivationProductType^.ActivationCardType;
      qSalesData^.CCCardNo := qActivationProductType^.ActivationCardNo;
      qSalesData^.CCPhoneNo := qActivationProductType^.ActivationPhoneNo;
      qSalesData^.CCCardName := qActivationProductType^.ActivationCardName;
      qSalesData^.CCExpDate := qActivationProductType^.ActivationExpDate;
      qSalesData^.CCEntryType := qActivationProductType^.ActivationEntryType;
      qSalesData^.GiftCardRestrictionCode := qActivationProductType^.ActivationRestrictionCode;
      if (qActivationProductType^.ActivationEntryType = ENTRY_TYPE_BARCODE) then
      begin
        qSalesData^.CCCardName := CurrToStr(Plu.UPC);  // Product code
        qSalesData^.CCCardType := CT_PUSH_PIN;
      end;
      qSalesData^.ActivationTransNo := curSale.nTransNo;
      if (qSalesData^.ActivationState = asWaitBalance) then
      begin
        QueueBalanceInquiry(qSalesData);
        sd := AddActivationMessageLine('Waiting for balance.')
      end
      else if (qSalesData^.Qty > 0.0) then
      begin
        if qSalesData^.CCCardNo <> '' then
          sd := AddActivationMessageLine(RightStr(qSalesData^.CCCardNo, 4) + ' To be activated.')
        else
          sd := AddActivationMessageLine('To be activated.');
      end
      else
      begin
        FCardActivationTimeOut := Now() + PRODUCT_ACTIVATION_TIMEOUT_DELTA;
        QueueActivationRequest(qSalesData);
        sd := AddActivationMessageLine('De-Activating...');
      end;
      {$IFDEF FUEL_PRICE_ADJUST}
      DisplaySaleList(sd, False);
      {$ELSE}
      DisplaySaleList(sd);
      {$ENDIF}
      POSListBox.Refresh();
    end;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.FormShow
  Author:    Gary Whetton
  Date:      26-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.FormShow(Sender: TObject);
var
  i : Integer;
  Ver : string;
  CWMsg : string;
  jcc : integer;
  plhost : string;
  plport : word;
begin
  {$IFDEF DEBUG}
  UpdateExceptLog('TfmPOS.FormShow');
  {$ENDIF}
  PumpLockMgr := nil;
  Zipper:= TAbZipper.create(Self);
  if (Now < FileDateToDateTime(FileAge(Application.ExeName))) then
  begin
    POSError('Error! The system clock is wrong.  Call Support! ');
    Application.Terminate;
    Exit;
  end;

  if not IdSSLOpenSSLHeaders.Load() then
  begin
    POSError('Cannot load OpenSSL headers, terminating.');
    updateExceptLog('OpenSSL loading failed: %s', [WhichFailedToLoad()]);
    Application.Terminate;
  end;

  {$IFDEF DEBUG}UpdateExceptLog('Setting Encryption Keys');{$ENDIF}
  SetKeys(GetEncryptKey1(), GetEncryptKey2(), GetEncryptKey1());

  DwrDeviceType := 0;  //20070228a
  bPrintingPriorReceipt := False;  //20070529a
  //  get the register number out of the registry
  fmPOSMsg.ShowMsg('Reading Terminal Config...', '');
  if not POSDataMod.IBDB.TestConnected then
    OpenTables(false);
  Ver := GetBuildInfoString;
  {$IFDEF DEBUG}UpdateExceptLog('Initializing POSDM');{$ENDIF}
  POSDataMod.Init();
  DBInt.LoadSetup(POSDataMod.IBSetupQuery, @Setup);
  Assert(Setup.DBVersionID <> 0, 'DBVersionID is 0');

  if (Setup.DBVersionID < 120100) then
  begin
    POSError('Database Version is too old.  Call Support');
    Application.Terminate;
    Exit;
  end;

  {$IFDEF DAX_SUPPORT}
  bDAXDBConfigured := (Setup.DBVersionID >= DB_VERSION_ID_DAX);
  if not bDAXDBConfigured then
    UpdateExceptLog('WARNING:  Latitude.exe version supports DAX, but DB version does not (DB Version: ' + IntToStr(Setup.DBVersionID) + ').');
  {$ENDIF}
    
  bTempLogon                  := False;

  bClosingPOS := False;

  ReportToDisk   := False;
  POSRegEntry    := TRegIniFile.Create('Latitude');
  ShowCursor(POSRegEntry.ReadBool('LatitudeConfig','ShowCursor',False));
  ThisTerminalNo  := POSRegEntry.ReadInteger( 'LatitudeConfig', 'TerminalNo', 999);
  CreditHost := POSRegEntry.ReadString('LatitudeConfig', 'CreditHost', 'localhost');
  FuelHost := POSRegEntry.ReadString('LatitudeConfig', 'FuelHost', 'localhost');
  MCPHost := POSRegEntry.ReadString('LatitudeConfig', 'Server', 'localhost');
  MOHost := POSRegEntry.ReadString('LatitudeConfig', 'MOHost', 'localhost');
  cipherlist := POSRegEntry.ReadString('LatitudeConfig', 'cipherlist', 'ADH-AES256-SHA');
  if ThisTerminalNo = 999 then
  begin
    fmSetTerminal.ShowModal;
    POSRegEntry.WriteInteger( 'LatitudeConfig', 'TerminalNo', ThisTerminalNo );
  end;
  bLogging := POSRegEntry.ReadBool('LatitudeConfig', 'Logging', False);
  SyncLogs := POSRegEntry.ReadBool('LatitudeConfig', 'SyncLogging', False);
  bPPLogging := POSRegEntry.ReadBool('LatitudeConfig', 'PPLogging', False);
  bFuelMsgLogging := POSRegEntry.ReadBool('LatitudeConfig', 'FuelMsgLogging', False);
  UpdateLoggingDisplay();
  UpdatePPLoggingDisplay();
  UpdateFuelLoggingDisplay();
  POSRegEntry.Free;
  Config := TConfigRW.CreateCur(POSDataMod.CursorBuild());
  Config.AutoCommit := True;
  try
    ConsolidateShifts := Config.Bool['SYS_CNSLDTE_SHIFTS'];
  except
    ConsolidateShifts := False;
  end;
  {$IFDEF DEBUG}UpdateExceptLog('Initializing FPC thread');{$ENDIF}
  try
    StartFPCThread;
  except
  end;

  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from Terminal where TerminalNo = :pThisTerminalNo');
    parambyname('pThisTerminalNo').AsString := IntToStr(ThisTerminalNo);
    Open;
    if RecordCount = 0 then
    begin
      close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      ShowMessage ('Error ! Terminal must be configured in Latitude Setup! ');
      Application.Terminate;
      Exit;
    end;
    bFuelSystem      :=  Boolean(FieldByName('FuelSystem').AsInteger);
    bTouchScreen     :=  Boolean(FieldByName('TouchScreen').AsInteger);
    // left handed must be updated if kybd defined by cashier
    // current default is to terminal setting
    POSTerminalHardware  := FieldByName('TerminalHardware').AsInteger;
    ThisTerminalUNCName  := FieldByName('TerminalName').AsString;
    if (FieldByName('AppDrive').AsString >= 'C') and
       (FieldByName('AppDrive').AsString <= 'Z') then
      ThisTerminalAppDrive := FieldByName('AppDrive').AsString
    else
      ThisTerminalAppDrive := 'C';
    POSScreenSize   := FieldByName('ScreenMode').AsInteger;
    bAutoFont := False;
    if POSScreenSize = 3 then
    begin
      if Screen.Width = 800 then
      begin
        POSScreenSize := 2;
        bAutoFont := True;
      end
      else if Screen.Width = 1024 then
        POSScreenSize := 1
      else if Screen.Width = 1280 then
        POSScreenSize := 4;
    end;
    close;
  end;
  with POSDataMod.IBTempQuery do
  begin
    close;SQL.Clear;
    // Get the name and number of the masterterminal
    SQL.Add('Select * from Terminal where TerminalType = 1');
    Open;
    if RecordCount = 0 then
    begin
      close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      ShowMessage ('Error ! A Master Terminal must be defined in Latitude Setup! ');
      Application.Terminate;
      Exit;
    end;
    MasterTerminalNo       := FieldByName('TerminalNo').AsInteger;
    MasterTerminalUNCName  := FieldByName('TerminalName').AsString;
    if (FieldByName('AppDrive').AsString >= 'C') and
       (FieldByName('AppDrive').AsString <= 'Z') then
      MasterTerminalAppDrive := FieldByName('AppDrive').AsString
    else
      MasterTerminalAppDrive := 'C';
    close;
  end;
  with POSDataMod.IBTempQuery do
  begin
    close;SQL.Clear;
    BackupTerminalNo       := 0;
    BackUpTerminalUNCName  := '';
    BackUpTerminalAppDrive := 'C';
    // Get the name and number of the Back Up Terminal
    SQL.Add('Select * from Terminal where TerminalType = 2');
    Open;
    if RecordCount > 0 then
    begin
      BackupTerminalNo       := FieldByName('TerminalNo').AsInteger;
      BackUpTerminalUNCName  := FieldByName('TerminalName').AsString;
      if (FieldByName('AppDrive').AsString >= 'C') and
         (FieldByName('AppDrive').AsString <= 'Z') then
        BackUpTerminalAppDrive := FieldByName('AppDrive').AsString;
    end;
    close;
  end;
  EL_MTUN := MasterTerminalUNCName;
  EL_MTAD := MasterTerminalAppDrive;
  EL_TTN  := ThisTerminalNo;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;

  {$IFDEF DEBUG}UpdateExceptLog('Updating log names');{$ENDIF}
  ExceptLog.UpdateLogName;

  // Listen for Eject requests to know when to get out of the database  
  //if ThisTerminalNo <> MasterTerminalNo then
  //  POSDataMod.RegIBEventNotification('Eject', Self.OnIBEjectRequest);

  UpdateZLog('About to initialize AdManageMod');
  //AdManageMod.Init();
  UpdateZLog('Done initializing AdManageMod');

  {$IFDEF DEBUG}UpdateExceptLog('Done initializing AdManageMod');{$ENDIF}

  fmPOS.Left   := 0;
  fmPOS.Top    := 0;
  case POSScreenSize of
  1 :
    begin
      fmPOS.Height := 763;   //     573;
      fmPOS.Width  := 1024;  //     800;
    end;
  2 :
    begin
      fmPOS.Height := 595;
      fmPOS.Width  := 800;
    end;
  4 :
    begin
      fmPOS.Height := 1027;   //     573;
      fmPOS.Width  := 1280;  //     800;
    end;
  end;

  {$IFDEF DEV_PIN_PAD}
  LastValidCardInfo.bSwipeAtPINPad := False;
  LastValidCardInfo.Orig           := '';
  LastValidCardInfo.Track1Data     := '';
  LastValidCardInfo.Track2Data     := '';
  LastValidCardInfo.CardNo         := '';
  LastValidCardInfo.ExpDate        := '';
  LastValidCardInfo.ServiceCode    := '';
  LastValidCardInfo.CardName       := '';
  LastValidCardInfo.VehicleNo      := '';
  LastValidCardInfo.CardError      := '';
  LastValidCardInfo.CardType       := '';
  LastValidCardInfo.CardTypeName   := '';
  LastValidCardInfo.iFaceValueCents := 0;
  LastValidCardInfo.bActivationType := False;
  LastValidCardInfo.bGetDriverID   := False;
  LastValidCardInfo.bGetOdometer   := False;
  LastValidCardInfo.bGetRefNo      := False;
  LastValidCardInfo.bGetVehicleNo  := False;
  LastValidCardInfo.bGetZIPCode    := False;
  LastValidCardInfo.bAskDebit      := False;
  LastValidCardInfo.bDebitBINMngt  := False;
  {$ENDIF}

  ClearActivationProductData(@ActivationProductData);

  //Gift
  // Constant strings used for descriptions of gift card restriction codes.
  GIFT_CARD_RESTRICTION_DESC[RC_UNKNOWN] := RC_UNKNOWN_DESC;
  GIFT_CARD_RESTRICTION_DESC[RC_NO_RESTRICTION] := RC_NO_RESTRICTION_DESC;
  GIFT_CARD_RESTRICTION_DESC[RC_NO_SIN] := RC_NO_SIN_DESC;
  GIFT_CARD_RESTRICTION_DESC[RC_ONLY_FUEL] := RC_ONLY_FUEL_DESC;

  // Critical seciton to make ProcessKeyMED() single threaded.
  FPinCreditSelect := PIN_NO_TYPE;
  //Gift

  //this is just so the load messages show up below the logo on the splash screen

  fmPOSMsg.Position := poDesigned;
  case POSScreenSize of
  1 :
    begin
      fmPOSMsg.Left     := Trunc(( 1024 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 500;
    end;
  2 :
    begin
      fmPOSMsg.Left     := Trunc(( 800 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 375;
    end;
  4 :
    begin
      fmPOSMsg.Left     := Trunc(( 1280 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 625;
    end;
  end;

  {$IFDEF DEBUG}UpdateExceptLog('Playing POS Start sound');{$ENDIF}

  bPlayWave := PlaySound( 'POSSTART', HInstance, SND_ASYNC or SND_RESOURCE) ;
  Receiptlist := TList.Create;
  ReceiptList.Clear;
  ReceiptList.Capacity := ReceiptList.Count;

  try
    for jcc := 0 to NUM_CREDIT_CLIENTS - 1 do
    begin
      CreditClient[jcc].CreditTransNo   := TRANSNO_NONE;
      CreditClient[jcc].ActivateTransNo := TRANSNO_NONE;
    //20020205...
      CreditClient[jcc].bCreditAuthFailed := False;
    //...20020205
      CreditClient[jcc].GiftCardActivateList := TList.Create;
      CreditClient[jcc].GiftCardActivateList.Clear;
      CreditClient[jcc].GiftCardUsedList := TList.Create;
      CreditClient[jcc].GiftCardUsedList.Clear;
    end;
  except
    UpdateExceptLog('Credit Client array initialization error');
  end;
  qClient                := @(CreditClient[NORM_CREDIT_CLIENT]);
  qSuspendedCreditClient := qClient;
  qSuspendedClient       := qClient;
  //Gift
  //cwa...
  try
    for jcc := 0 to NUM_CARWASH_CLIENTS - 1 do
    begin
      CarwashClient[jcc].CarwashTransNo   := TRANSNO_NONE;
      CarwashClient[jcc].CWAccessType     := GC_NONE;
    end;
  except
    UpdateExceptLog('Carwash Client array initialization error');
  end;
  qCWClient              := @(CarwashClient[NORM_CARWASH_CLIENT]);
  sCarwashAccessCode := '';
  //...cwa
  //cwf...
  sCarwashExpDate := '';
  //...cwf
  //cwj...
  fCarwashTotals := False;
  //...cwj


  InitializeCriticalSection(CSSuspendList);

  FSList := TThreadList.Create();
  CCList := TThreadList.Create();
  MOList := TThreadList.Create();
  
  BuildRestrictedDeptList();
  BuildCardTypeList();
  //Gift

  InitScreen;
  ClearEntryField;

  //CheckCCBatch;

  ConnectMCP;
  if Setup.CreditAuthType <> 1 then
  begin
    fmPOSMsg.ShowMsg('Connecting to Credit Server...', '');
    ConnectCreditServer;
  end;

  bLeftHanded := False;
  bScreenBuilt := False;
  LoadSetup;
  CheckCCBatch;
  bScreenBuilt := True;

  fmPOSMsg.Position := poDesigned;
  case POSScreenSize of
  1 :
    begin
      fmPOSMsg.Left     := Trunc(( 1024 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 500;
    end;
  2 :
    begin
      fmPOSMsg.Left     := Trunc(( 800 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 375;
    end;
  4 :
    begin
      fmPOSMsg.Left     := Trunc(( 1280 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 625;
    end;
  end;

  NO_PUMPS := Setup.NoPumps;
  If NO_PUMPS > MaxPumps Then
    NO_PUMPS := MaxPumps;

  if bFuelSystem then
  begin
    CreatePumpIcons (Sender);  // Moved up from below the OLE Junk...
    fmPOSMsg.ShowMsg('Connecting to Fuel Server...', '');
    ConnectFuelServer;
  end;
  fmPumpInfo.Pumps := nPumpIcons;

  try
    plhost := Config.Str['PL_HOST'];
    plport := Config.Int['PL_PORT'];
    PumpLockMgr := TPumpLockMgr.Create(nil, plhost, plport, ThisTerminalNo, nPumpIcons);
  except
    on E : Exception do
      UpdateExceptLog('Problem setting up Pump Lock Manager: %s', [e.message]);
  end;

  //cwa...
  if Setup.CarWashInterfaceType <> CWSRV_NONE then
    begin
      fmPOSMsg.ShowMsg('Connecting to Car Wash Server...', '');
      ConnectCarWashServer();
      if ThisTerminalNo = MasterTerminalNo then
        begin
          CWMsg := BuildTag(TAG_MSGTYPE, IntToStr(CW_RESUME_SERVER));
          SendCarWashMessage(CWMsg);
        end;
    end;
  //...cwa
  if Setup.MOSystem then
  begin
    fmPOSMsg.ShowMsg('Connecting to Money Order Printer...','');
    ConnectMOServer(False);
  end;

  fmPOSMsg.Close;
  fmPOSMsg.Position := poScreenCenter;

  {We adjust the size of the Errordisplay to the size of the Statusbar }

  For i := 1 to MaxPumps do
  Begin
    ErrorStatusArr[i] := 0;
  End;

  bErrorDisplayOn := False;

  bPostingSale := False;
  bPostingCATSale := False;
  bPostingPrePaySale := False;
  bPOSForceClose := False;

  Timer1.Enabled := True;

  {We want to hide the application TASKBAR icon }
  ShowWindow( POSMenu.Handle, SW_HIDE );
  Application.ProcessMessages;
  Application.ShowMainForm := False;

  pstSale.nTransNo := 0;
  LogPOSStart;
  nSeqLink := 0;

  // since we just loaded, reset the reload flag so the first user doesn't
//   have to wait again
  if not POSDataMod.IBTransaction.InTransaction then       //Shesh   to allow login box to come
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Update Terminal Set ReloadSetup = 0 where TerminalNo = ' + IntToStr(ThisTerminalNo) );
    ExecSQL;
    close;
  end;

  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;

  {User sign on}
  PostMessage(fmPOS.Handle,WM_FIRSTLOGON,0,0);  // madhu g v   user login

  ShowWindowAsync( Application.Handle, SW_HIDE );
  fmPOSIcon := TTrayIcon.Create(Self);
  fmPOSIcon.Icon.Handle := LoadIcon(HInstance, 'APOSICON');
  fmPOSIcon.Active := True;
  fmPOSIcon.PopUpMenu := PopUpMenu1;
  fmPOSIcon.Tooltip := 'Latitude' + #13 + 'POS' + #13 + Ver;

  SysMgrIcon := TTrayIcon.Create(Self);
  SysMgrIcon.Icon.Handle := LoadIcon(HInstance, 'BOICON');
  SysMgrIcon.Active := True;
  SysMgrIcon.PopUpMenu := SysmgrPopup;

  Ver := GetFileVersionStr('\Latitude\SysMgr.exe');
  SysMgrIcon.Tooltip := 'Latitude' + #13 + 'System Manager' + #13 + Ver;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.FirstLogOn
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TMessage
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.FirstLogOn(var Msg: TMessage);
begin
  ProcessKeyUSO;
  PopUpMsgTimer.Enabled := True;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.LoadSetup
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.LoadSetup;
var
  ndx, i : Integer;
//cwe  CATCount : integer;
  //Gift
  jcc : integer;
  //Gift
begin
  fmPOSMsg.Position := poDesigned;
  case POSScreenSize of
  1 :
    begin
      fmPOSMsg.Left     := Trunc(( 1024 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 500;
    end;
  2 :
    begin
      fmPOSMsg.Left     := Trunc(( 800 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 375;
    end;
  4 :
    begin
      fmPOSMsg.Left     := Trunc(( 1280 - fmPOSMsg.Width ) / 2 ) ;
      fmPOSMsg.Top      := 625;
    end;
  end;

  fmPOSErrorMsg.CapturePLU := False;

  if POSDataMod.IBDB.TestConnected   = false then
  begin
    fmPOSMsg.ShowMsg('Opening Tables...', '');
    OpenTables(True);
  end;

  bCaptureNFPLU    := False;
  bNeedModifier    := False;
  curSale.bSalesTaxXcpt    := False;
  bSuspendedSale   := False;
  lSuspend.Visible := False;
  lSuspend.Tag     := 0;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('select MediaNo from Media where RecType = 1 Order By MediaNo' );
    Open;
    if recordcount > 0 then
      CASH_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;

    Close;SQL.Clear;
    SQL.Add('select MediaNo from Media where RecType = 2 Order By MediaNo' );
    Open;
    if recordcount > 0 then
      CHECK_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;

    Close;SQL.Clear;
    SQL.Add('select MediaNo, Name from Media where RecType = 3 Order By MediaNo' );
    Open;
    if eof then
      sCreditMediaNo := inttostr(CREDIT_MEDIA_NUMBER)
    else
    begin
      sCreditMediaNo   := FieldByName('MediaNo').AsString;
      CREDIT_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;
      sCreditMediaName := FieldByName('Name').AsString;
    end;

    Close;SQL.Clear;
    SQL.Add('select MediaNo, Name from Media where RecType = 4 Order By MediaNo' );
    Open;
    if eof then
      sDebitMediaNo := inttostr(DEBIT_MEDIA_NUMBER)
    else
    begin
      sDebitMediaNo   := FieldByName('MediaNo').AsString;
      DEBIT_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;
      sDebitMediaName := FieldByName('Name').AsString;
    end;

    Close;SQL.Clear;
    SQL.Add('select MediaNo from Media where RecType = 5 Order By MediaNo' );
    Open;
    if recordcount > 0 then
      COUPON_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;

    Close;SQL.Clear;
    SQL.Add('select MediaNo from Media where RecType = 6 Order By MediaNo' );
    Open;
    if recordcount > 0 then
      FOOD_STAMP_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger
    else
      FOOD_STAMP_MEDIA_NUMBER := 0;

    Close;SQL.Clear;
    SQL.Add('select MediaNo, Name from Media where RecType = 7 Order By MediaNo' );
    Open;
    if eof then
    begin
      sGiftCardMediaNo := IntToStr(DEFAULT_GIFT_CARD_MEDIA_NUMBER);
      sGiftCardMediaName := 'Gift Card';
    end
    else
    begin
      sGiftCardMediaNo   := FieldByName('MediaNo').AsString;
      DEFAULT_GIFT_CARD_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;
      sGiftCardMediaName := FieldByName('Name').AsString;
    end;

    Close;SQL.Clear;
    SQL.Add('select MediaNo, Name from Media where RecType = 8 Order By MediaNo' );
    Open;
    if eof then
      sEBTFSMediaNo := '0'
    else
    begin
      sEBTFSMediaNo   := FieldByName('MediaNo').AsString;
      EBT_FS_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;
      sEBTFSMediaName := FieldByName('Name').AsString;
    end;

    Close;SQL.Clear;
    SQL.Add('select MediaNo, Name from Media where RecType = 9 Order By MediaNo' );
    Open;
    if eof then
      sEBTCBMediaNo := '0'
    else
    begin
      sEBTCBMediaNo   := FieldByName('MediaNo').AsString;
      EBT_CB_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;
      sEBTCBMediaName := FieldByName('Name').AsString;
    end;

//20071019a    {$IFDEF FUEL_FIRST}
    Close;SQL.Clear;
    SQL.Add('select MediaNo, Name from Media where Name = :pName' );
    ParamByName('pName').AsString := 'Drive Off';
    Open;
    if eof then
      sDriveOffMediaNo := '0'
    else
    begin
      sDriveOffMediaNo   := FieldByName('MediaNo').AsString;
      DRIVE_OFF_MEDIA_NUMBER := FieldByName('MediaNo').AsInteger;
      sDriveOffMediaName := FieldByName('Name').AsString;
    end;
//20071019a    {$ENDIF}

    Close;SQL.Clear;
    SQL.Add('Select * from Sounds');
    Open;
    DriveOffNoise := FieldByName('DriveOff').AsInteger;
    RespondNoise := FieldByName('Response').AsInteger;
    ValidateAgeNoise := FieldByName('ValidateAge').AsInteger;
    EnterDateNoise := FieldByName('EnterDate').AsInteger;
    CATHelpNoise := FieldByName('PumpHelp').AsInteger;
    Close;

    UpdateZLog('DebitAllowed or GiftCardAllowed or EBTFSAllowed-tarang');
    //ShowMessage('DebitAllowed or GiftCardAllowed or EBTFSAllowed '); // madhu remove
    SQL.Clear;
    SQL.Add('select * from ccSetup where ccno = (select CreditAuthType from Setup)');
    Open;
    if NOT eof then
    begin
      bDebitAllowed := boolean(fieldbyname('DebitAllowed').AsInteger);
      bGiftAllowed  := boolean(fieldbyname('GiftCardAllowed').AsInteger);
      bEBTFSAllowed := boolean(fieldbyname('EBTFSAllowed').AsInteger);         // EBT Food Stamp allowed
      bEBTCBAllowed := boolean(fieldbyname('EBTCBAllowed').AsInteger);         // EBT Cash Benefit allowed
      bCreditSelectNeeded := bDebitAllowed or bEBTFSAllowed or bEBTCBAllowed;  // Gift is treated like credit.
      bSyncF1EOD    := boolean(fieldbyname('SyncF1EOD').AsInteger);
      PAN           := boolean(fieldbyname('PAN').AsInteger);
      bGiftRestrictions := boolean(fieldbyname('GiftRestrictions').AsInteger);

      sTerminalID := FieldByName('TerminalID').AsString;
      nCashBackType := FieldByName('CashBackType').AsInteger;
      nMaxCashBack := FieldByName('MaxCashBack').AsCurrency;
      nCashAmount1 := FieldByName('CashAmount1').AsCurrency;
      nCashAmount2 := FieldByName('CashAmount2').AsCurrency;
      nCashAmount3 := FieldByName('CashAmount3').AsCurrency;
    end;
    Close;
  end;

  DBInt.LoadSetup(POSDataMod.IBSetupQuery, @Setup);

  GiftCardDeptNo       := Setup.GiftCardDeptNo;
  GiftCardFaceValueMin := Setup.GiftCardFaceValueMin;
  GiftCardFaceValueMax := Setup.GiftCardFaceValueMax;
  GiftCardFaceValueInc := Setup.GiftCardFaceValueInc;
  bClearDisplayAfterError := True;  // Normally, display will be cleared after error message.
//bpz...
{$IFDEF CAT_SIMULATION}
  bCATSimulation := False;
  CATSimulationTrack1 := '';
  CATSimulationTrack2 := '';
{$ENDIF}
//...bpz
  //Gift
  nMaxCashBack := 0;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  bScanStarted := False;

  bCashDrawerActive := 0;
  bCoinDispenserActive := 0;
  bPoleActive       := 0;
  iPoleType         := 0;
  bMSRActive        := 0;
  bPINPadActive     := 0;
  bReceiptActive    := 0;
  bKeyboardActive   := 0;
  bPriceSignActive  := 0;
  bScannerActive    := 0;

  bUseFoodStamps   := Boolean(Setup.FoodStampItems);
  bSyncShiftChange := Boolean(Setup.SyncShiftChange);
  bCompulseDwr     := Boolean(Setup.CompulseDwr);
  bCutReceipt      := Boolean(Setup.AutoCutReceipt);
  nDwrLimit        := Setup.DwrLimit;
  sPoleOpenMess    := Setup.ScrollOpenMess;
  sPoleCloseMess   := Setup.ScrollCloseMess;
  bPrintVoids      := Boolean(Setup.PrintVoids);
  nPumpAuthMode    := Setup.PumpAuthMode;

  nUseStartingTill := Setup.UseStartingTill;
  nStartingTillDefault := Setup.StartingTillDefault;

  bEODRptDaily    := Boolean(Setup.EODRptDaily);
  bEODRptHourly   := Boolean(Setup.EODRptHourly);
  bEODRptFuelTls  := Boolean(Setup.EODRptFuelTls);
  bEODRptCashDrop := Boolean(Setup.EODRptCashDrop);
  bEODRptPLU      := Boolean(Setup.EODRptPLU);

  bEOSRptDaily    := Boolean(Setup.EOSRptDaily);
  bEOSRptHourly   := Boolean(Setup.EOSRptHourly);
  bEOSRptFuelTls  := Boolean(Setup.EOSRptFuelTls);
  bEOSRptCashDrop := Boolean(Setup.EOSRptCashDrop);
  bEOSRptPLU      := Boolean(Setup.EOSRptPLU);

  bEOSRptCredit      := Boolean(Setup.EOSRptCredit);
  bEOSBatchBalance   := Boolean(Setup.EOSBatchBalance);

  bUseDefaultModifier := Boolean(Setup.UseDefModifier);
  nTillTimer          := Setup.TillTimer;
  nDaysHistory        := Setup.DaysHistory;
  nDaysBackup         := Setup.DaysBackup;

  nAgeValidationType := Setup.AgeValidationType;
  for i:= 1 to NO_PUMPS do
    begin
      if not (nPumpIcons[i] = nil) then
        begin
          nPumpIcons[i].CATHintTimeout  := Setup.CATHintTimeout;
          nPumpIcons[i].CATHintInterval := Setup.CATHintInterval;
        end;
    end;
  nNextDollarKey := 0;

  fmPOSMsg.ShowMsg('Loading Local Lookup Tables...', '');
  POSDataMod.PLUMemTable.Close;
  POSDataMod.PLUMemTable.Open;
  POSDataMod.PLUMemTable.EmptyTable;
  POSDataMod.PLUMemTable.Close;

  fmPOSMsg.ShowMsg('Initializing Ports...', '');
  SetupPorts;

  sReportLogName := '';
  sDataLogName := '';

  fmPOSMsg.ShowMsg('Configuring Master/Backup...', '');
  BackupTerminalNo       := 0;
  BackUpTerminalUNCName  := '';
  BackUpTerminalAppDrive := 'C';
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    // Get the name and number of the masterterminal
    Close;SQL.Clear;
    SQL.Add('Select * from Terminal where TerminalType = 1');
    Open;
    if eof then
    begin
      close;
      POSDataMod.IBTransaction.Commit;
      //ShowMessage ('Error ! A Master Terminal must be defined in Latitude Setup! ');
      Application.Terminate;
      Exit;
    end;
    MasterTerminalNo       := FieldByName('TerminalNo').AsInteger;
    MasterTerminalUNCName  := FieldByName('TerminalName').AsString;
    if (FieldByName('AppDrive').AsString >= 'C') and
       (FieldByName('AppDrive').AsString <= 'Z') then
      MasterTerminalAppDrive := FieldByName('AppDrive').AsString
    else
      MasterTerminalAppDrive := 'C';
    close;

    // Get the name and number of the Back Up Terminal
    SQL.Clear;
    SQL.Add('Select * from Terminal where TerminalType = 2');
    Open;
    if Not eof then
    begin
      BackupTerminalNo       := FieldByName('TerminalNo').AsInteger;
      BackUpTerminalUNCName  := FieldByName('TerminalName').AsString;
      if (FieldByName('AppDrive').AsString >= 'C') and
             (FieldByName('AppDrive').AsString <= 'Z') then
        BackUpTerminalAppDrive := FieldByName('AppDrive').AsString;
    end;
    close;
  end;

  sReportLogName := '\\' + MasterTerminalUNCName + '\' + MasterTerminalAppDrive + '\Latitude\RptLog' + IntToStr(ThisTerminalNo) + '.txt';
  if (BackUpTerminalNo > 0) and (BackUpTerminalUNCName > '') then
    sDataLogName   := '\\' + BackUpTerminalUNCName + '\' + BackupTerminalAppDrive + '\Latitude\DataLog' + IntToStr(ThisTerminalNo) + '.txt';
  //  sShiftReportPrefix := '\\' + FieldByName('TerminalName').AsString + '\' + AppDrive + '\Latitude\';

  with POSDataMod.IBTempQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select CurShift from Terminal Where TerminalNo = ' + IntToStr(ThisTerminalNo));
    Open;
    nShiftNo := FieldByName('CurShift').AsInteger;
    Close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  POSDate := Date;

  with StatusBar1 do
  begin
    //set to align to the bottom of the screen
    Left := 0;
    Height := 40;
    Width := Screen.Width - 8;
    Panels.Items[0].Text := 'Terminal# ' + IntToStr(ThisTerminalNo) + ' Shift# ' + InttoStr (nShiftNo);
    Panels.Items[1].Text := 'Trans#';
    Panels.Items[2].Text := FormatDateTime('dddd, mmm d,yyyy',POSDate);
    Panels.Items[3].Text := FormatDateTime('h:mm AM/PM',Time);
  end;

  UpdateIndicatorLocations(StatusBar1);


  {fmPOSMsg.ShowMsg('Configuring POS Keyboard...');
  LoadKeyBoard;   // Loads KYBD into Memory (KBDef)
  }
  //ShowMessage('Finalizing Configuration.'); // madhu remove
  fmPOSMsg.ShowMsg('Finalizing Configuration...', '');

  sPumpNo := '';
  bSkipOneKey := False;
  MessageCount :=  0;
  KeyCount :=  0;
  nTimercount := 0;

  DAYCLOSEInProgress := False;
  EODInProgress := False;

  // Printer & Receipt
  POST_PRINT := (Setup.Printmode = 1);
  PRINT_ON_REQUEST := (Setup.Printmode = 2);

  // Security, Import and Export
  Security_Active  := (Setup.Security = 1);

  if Setup.EOSExport > 1 then EOSExports := True;
  if Setup.EODExport > 1 then EODExports := True;

  EODExportPath    :=  Setup.EODExportPath;
  FuelPriceImport  := (Setup.FuelPriceImport = 1);
  FuelPricePath    :=  Setup.FuelPricePath;

  if ReceiptList.Count > 0 then
  for ndx := 0 to ReceiptList.Count - 1 do
  begin
    ReceiptData := ReceiptList.Items[ndx];
    Dispose(ReceiptData);
    ReceiptList.Items[Ndx] := nil;
  end;
  ReceiptList.Pack;
  ReceiptList.Clear;
  ReceiptList.Capacity := ReceiptList.Count;
  LoadPrinterSettings;

  if CurSaleList.Count > 0 then
    DisposeSalesListItems(CurSaleList);
  CurSaleList.Pack;
  CurSaleList.Clear;
  CurSaleList.Capacity := CurSaleList.Count;

  EnterCriticalSection(CSTaxList);  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  try // PROGRAMMING WARNING:  Do not exit this try block without leaving critical section.
    if CurSalesTaxList.Count > 0 then
      DisposeTListItems(CurSalesTaxList);
  except
  end; // try/except
  LeaveCriticalSection(CSTaxList);  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

  //Gift
  for jcc := 0 to NUM_CREDIT_CLIENTS - 1 do
  begin
    CreditClient[jcc].CreditTransNo   := TRANSNO_NONE;
    CreditClient[jcc].ActivateTransNo := TRANSNO_NONE;
    //20020205...
    CreditClient[jcc].bCreditAuthFailed := False;
    //...20020205
    CreditClient[jcc].RestrictSalesTaxList.Pack;
    CreditClient[jcc].RestrictSalesTaxList.Clear;
    CreditClient[jcc].RestrictSalesTaxList.Capacity := CreditClient[jcc].RestrictSalesTaxList.Count;
  end;
  //Gift
  //cwa...
  for jcc := 0 to NUM_CARWASH_CLIENTS - 1 do
  begin
    CarwashClient[jcc].CarwashTransNo   := TRANSNO_NONE;
    CarwashClient[jcc].CWAccessType     := GC_NONE;
  end;
  //...cwa
  //20041215...
  EnterCriticalSection(CSTaxList);  // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  try // PROGRAMMING WARNING:  Do not exit this try block without leaving critical section.
  //...20041215 (following block indented as part of change)
    CurSalesTaxList.Pack;
    CurSalesTaxList.Clear;
    CurSalesTaxList.Capacity := CurSalesTaxList.Count;
  //20041215... (previous block indented as part of change)
  except
  end;
  LeaveCriticalSection(CSTaxList);  // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
  //...20041215
  if PostSalesTaxList.Count > 0 then
  for ndx := 0 to PostSalesTaxList.Count - 1 do
  begin
    PostSalesTax := PostSalesTaxList.Items[ndx];
    Dispose(PostSalesTax);
    PostSalesTaxList.Items[Ndx] := nil;
  end;
  PostSalesTaxList.Pack;
  PostSalesTaxList.Clear;
  PostSalesTaxList.Capacity := PostSalesTaxList.Count;

  if SavSalesTaxList.Count > 0 then
  for ndx := 0 to SavSalesTaxList.Count - 1 do
  begin
    SavSalesTax := SavSalesTaxList.Items[ndx];
    Dispose(SavSalesTax);
    SavSalesTaxList.Items[Ndx] := nil;
  end;
  SavSalesTaxList.Pack;
  SavSalesTaxList.Clear;
  SavSalesTaxList.Capacity := SavSalesTaxList.Count;

  InitTaxList;

  if PopUpMsgList.Count > 0 then
  for ndx := 0 to PopUpMsgList.Count - 1 do
  begin
    PopUpMsg := PopUpMsgList.Items[ndx];
    Dispose(PopUpMsg);
    PopUpMsgList.Items[Ndx] := nil;
  end;
  PopUpMsgList.Pack;
  PopUpMsgList.Clear;
  PopUpMsgList.Capacity := PopUpMsgList.Count;
  InitPopUpMsgList;


  InitScreen;
  ClearEntryField;
   UpdateZLog('before : BuildPOSTouchScreen-tarang');
 // ShowMessage('before : BuildPOSTouchScreen'); // madhu remove
  bLeftHanded := False;
  if bTouchScreen then
    BuildPOSTouchScreen;

  fmPOSMsg.Close;
  fmPOSMsg.Position := poScreenCenter;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
  //Kiosk
  if KioskFrame.KioskActive then
    bKioskActive := true
  else
    bKioskActive := False;
  //Kiosk

  //20060719...
  // Department numbers for fuel
  DEPT_NO_UNLEADED := 0;  // Will be reset below
  DEPT_NO_PLUS     := 0;  // Will be reset below
  DEPT_NO_SUPER    := 0;  // Will be reset below
  DEPT_NO_DIESEL   := 0;  // Will be reset below
  DEPT_NO_KEROSENE := 0;  // Will be reset below
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  try
    with POSDataMod.IBTempQuery do
    begin
      Close();
      SQL.Clear();
      SQL.Add('select DeptNo from Dept d inner join Grp g on d.GrpNo = g.GrpNo where g.Fuel = 1');
      SQL.Add(' and (d.Name like ''%unleaded%'' or d.Name like ''%Unleaded%'' or d.Name like ''%UNLEADED%'')');
      Open;
      if (RecordCount = 1) then
        DEPT_NO_UNLEADED := FieldByName('DeptNo').AsInteger;

      Close();
      SQL.Clear();
      SQL.Add('select DeptNo from Dept d inner join Grp g on d.GrpNo = g.GrpNo where g.Fuel = 1');
      SQL.Add(' and (d.Name like ''%plus%'' or d.Name like ''%Plus%'' or d.Name like ''%PLUS%'')');
      Open;
      if (RecordCount = 1) then
        DEPT_NO_PLUS := FieldByName('DeptNo').AsInteger;

      Close();
      SQL.Clear();
      SQL.Add('select DeptNo from Dept d inner join Grp g on d.GrpNo = g.GrpNo where g.Fuel = 1');
      SQL.Add(' and (d.Name like ''%super%'' or d.Name like ''%Super%'' or d.Name like ''%SUPER%'')');
      Open;
      if (RecordCount = 1) then
        DEPT_NO_SUPER := FieldByName('DeptNo').AsInteger;

      Close();
      SQL.Clear();
      SQL.Add('select DeptNo from Dept d inner join Grp g on d.GrpNo = g.GrpNo where g.Fuel = 1');
      SQL.Add(' and (d.Name like ''%diesel%'' or d.Name like ''%Diesel%'' or d.Name like ''%DIESEL%'')');
      Open;
      if (RecordCount = 1) then
        DEPT_NO_DIESEL := FieldByName('DeptNo').AsInteger;

      Close();
      SQL.Clear();
      SQL.Add('select DeptNo from Dept d inner join Grp g on d.GrpNo = g.GrpNo where g.Fuel = 1');
      SQL.Add(' and (d.Name like ''%kero%'' or d.Name like ''%Kero%'' or d.Name like ''%KERO%'')');
      Open;
      if (RecordCount = 1) then
        DEPT_NO_KEROSENE := FieldByName('DeptNo').AsInteger;
      Close();
    end;
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  except
    on E : Exception do
    begin
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Rollback;
      UpdateExceptLog('Rollback setting fuel dept. #s ' + e.message);
    end;
  end;
  //Set to default values if not set from DB above.
  if (DEPT_NO_UNLEADED <= 0) then DEPT_NO_UNLEADED := 91;
  if (DEPT_NO_PLUS     <= 0) then DEPT_NO_PLUS     := 92;
  if (DEPT_NO_SUPER    <= 0) then DEPT_NO_SUPER    := 93;
  if (DEPT_NO_DIESEL   <= 0) then DEPT_NO_DIESEL   := 94;
  if (DEPT_NO_KEROSENE <= 0) then DEPT_NO_KEROSENE := 95;
  //...20060719
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.LoadPLUMemTable
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.LoadPLUMemTable;
begin

  POSDataMod.PLUMemTable.Close;
  POSDataMod.PLUMemTable.Open;
  POSDataMod.PLUMemTable.EmptyTable;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select pluno, upc, name, price from plu where ');
      //20070213a...
//      SQL.Add('modifiergroup < 1 or modifiergroup is null');
      SQL.Add('(modifiergroup < 1 or modifiergroup is null)');
      SQL.Add(' and (DelFlag = 0 or DelFlag is null)');
      //...20070213a
      Open;
      while not EOF do
        begin
          POSDataMod.PLUMemTable.Insert;
          POSDataMod.PLUMemTable.FieldByName('PLUNO').AsCurrency := FieldByName('pluno').AsCurrency;
          POSDataMod.PLUMemTable.FieldByName('UPC').AsCurrency := FieldByName('upc').AsCurrency;
          POSDataMod.PLUMemTable.FieldByName('NAME').AsString :=    FieldByName('name').AsString;
          POSDataMod.PLUMemTable.FieldByName('PRICE').AsCurrency := FieldByName('price').AsCurrency;
          POSDataMod.PLUMemTable.FieldByName('MODIFIERNO').AsInteger := 0;
          POSDataMod.PLUMemTable.Post;
          Next;
        end;
      Close;

      SQL.Clear;
      SQL.Add('Select pm.pluno pluno, pm.plumodifier modifierno, p.upc upc, p.name name2, m.modifiername name1, pm.pluprice price from plu p, plumod pm, modifier m where ');
      SQL.Add('pm.plumodifiergroup = m.modifiergroup and ');
      SQL.Add('pm.plumodifier = m.modifierno and ');
      SQL.Add('pm.pluno = p.pluno');
      SQL.Add(' and (p.DelFlag = 0 or p.DelFlag is null)');  //20070213a
      Open;
      while not EOF do
        begin
          POSDataMod.PLUMemTable.Insert;
          POSDataMod.PLUMemTable.FieldByName('PLUNO').Value      := FieldByName('pluno').AsCurrency;
          POSDataMod.PLUMemTable.FieldByName('UPC').Value        := FieldByName('upc').AsCurrency;
          POSDataMod.PLUMemTable.FieldByName('NAME').AsString    := (FieldByName('name1').AsString + FieldByName('name2').AsString);
          POSDataMod.PLUMemTable.FieldByName('PRICE').AsCurrency := FieldByName('price').AsCurrency;
          POSDataMod.PLUMemTable.FieldByName('MODIFIERNO').AsInteger := FieldByName('modifierno').AsInteger;
          POSDataMod.PLUMemTable.Post;
          Next;
        end;
      close;

    end;
  (POSDataMod.PLUMemTable.FieldByName('PLUNO') As TNumericField).DisplayFormat := '#';
  (POSDataMod.PLUMemTable.FieldByName('UPC') As TNumericField).DisplayFormat := '#';
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.BuildPOSTouchScreen
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.BuildPOSTouchScreen;
var
nKybdNdx, nBtnNo : short;
nRowNo, nColNo : integer;
  spacing, fsize, tboxh, btnoffs, btnsize, right, tw: integer;
begin
  spacing := 6;
  case POSScreenSize of
    1, 4 : begin
             fsize := 14;
             tboxh := 30;
             btnoffs := 65;
             btnsize := 60;
           end;
    else  begin
          fsize := 10;
          tboxh := 22;
          btnoffs := 51;
          btnsize := 47;
        end;
  end;
  if bFuelSystem then
  begin
    MaxKeyNo  := 59  ;  //  7 rows 8 cols + 3 special pump keys
    MaxKeyRow := 7   ;
    with PumpPanel do
    begin
      Visible := True;
      Top := 0;
      Left := 0;
      case POSScreenSize of
        1 :
          begin
            Height := 249;
            Width := 1024;
          end;
        2 :
          begin
            Height := 194;
            Width := 800;
          end;
        4 :
          begin
            Height := 349;
            Width := 1280;
          end;
      end;
      Color := clTeal;
      BevelInner := bvLowered;
      BevelOuter := bvNone;
    end;

    TopKeyPos := PumpPanel.Height + 11;

    for nBtnNo := 1 to 3 do
    begin
      if bScreenBuilt = False then
      begin
        POSButtons[nBtnNo] := TPOSTouchButton.Create(Self);
        POSButtons[nBtnNo].Parent  := Self;
      end;

      POSButtons[nBtnNo].Name := 'PumpButton' + IntToStr(nBtnNo);
      POSButtons[nBtnNo].Top     := PumpPanel.Height + spacing;

      case POSScreenSize of
        1 :
          begin
            if bLeftHanded then
              POSButtons[nBtnNo].Left    := ((nBtnNo - 1) * 175) + 550
            else
              POSButtons[nBtnNo].Left    := ((nBtnNo - 1) * 175) + 10;
          end;
        2 :
          begin
            if bLeftHanded then
              POSButtons[nBtnNo].Left    := ((nBtnNo - 1) * 136) + 412
            else
              POSButtons[nBtnNo].Left    := ((nBtnNo - 1) * 136) + 10;
          end;
        4 :
          begin
            if bLeftHanded then
              POSButtons[nBtnNo].Left    := ((nBtnNo - 1) * 175) + 550
            else
              POSButtons[nBtnNo].Left    := ((nBtnNo - 1) * 175) + 10;
          end;
      end;
      POSButtons[nBtnNo].Height  := 67;
      POSButtons[nBtnNo].Width   := 100;
      POSButtons[nBtnNo].Visible := True;
      POSButtons[nBtnNo].OnClick := POSButtonClick;
      POSButtons[nBtnNo].KeyCode := 'P' + IntToStr(nBtnNo);
      POSButtons[nBtnNo].Tag := nBtnNo;
      POSButtons[nBtnNo].FrameStyle := bfsNone;
      POSButtons[nBtnNo].WordWrap := True;
      POSButtons[nBtnNo].Glyph.LoadFromResourceName(HInstance, 'BIGBLU_RT');
    end;
    nBtnNo := 4;

    with KeyPanel do
    begin
      Top := TopKeyPos - spacing;
      case POSScreenSize of
        1 :
          begin
            if bLeftHanded then
              Left    := 5
            else
              Left    := 495;
            Width   := 525;
            Height  := 460;
          end;
        2 :
          begin
            if bLeftHanded then
              Left    := 5
            else
              Left    := 386;
            Width   := 410;
            Height  := 360;
          end;
        4 :
          begin
            if bLeftHanded then
              Left    := 5
            else
              Left    := 495;
            Width   := 325;
            Height  := 660;
          end;
      end;
      Width := 8 * btnoffs + btnoffs - btnsize;
      Height := MaxKeyRow * btnoffs + btnoffs - btnsize;
    end;

    with lSuspend do
    begin
      Top := POSButtons[1].Top + POSButtons[1].Height + spacing;
      case POSScreenSize of
        1 :
          begin
            if bLeftHanded then
              Left    := 541
            else
              Left    := spacing;
            Width   := 173;
            Height  := 29;
            lSuspend.Font.Size := 12;
          end;
        2 :
          begin
            if bLeftHanded then
              Left    := 406
            else
              Left    := spacing;
            Width   := 130;
            Height  := 22;
            lSuspend.Font.Size := 9;
          end;
        4 :
          begin
            if bLeftHanded then
              Left    := 641
            else
              Left    := spacing;
            Width   := 273;
            Height  := 39;
            lSuspend.Font.Size := 12;
          end;
      end;
    end;

    with lbReturn do
    begin
      Top := POSButtons[1].Top + POSButtons[1].Height + spacing;
      case POSScreenSize of
      1 :
        begin
          if bLeftHanded then
            Left    := 665
          else
            Left    := 128;
          Width   := 89;
          Height  := 16;
          Font.Size := 12;
        end;
      2 :
        begin
          if bLeftHanded then
            Left    := 499
          else
            Left    := 96;
          Width   := 67;
          Height  := 12;
          Font.Size := 9;
        end;
      4 :
        begin
          if bLeftHanded then
            Left    := 665
          else
            Left    := 128;
          Width   := 89;
          Height  := 16;
          Font.Size := 12;
        end;
      end;
    end;

    with DisplayEntry do
    begin
      Top := POSButtons[1].Top + POSButtons[1].Height + spacing;
      Height  := tboxh;
      Font.Size := fsize;
      case POSScreenSize of
        1, 4 : Width   := 175 + 42;
        2 : Width   := 175;
        end;
      if bLeftHanded then
        Left    := PumpPanel.Width - spacing - Width
          else
        Left    := KeyPanel.Left - spacing - Width;
        end;

    with DisplayQty do
    begin
      Top := POSButtons[1].Top + POSButtons[1].Height + spacing;
      Font.Size := DisplayEntry.Font.Size;
      Height := DisplayEntry.Height;
      case POSScreenSize of
        1,4 : Width   := 49;
        2 : Width   := 37;
          end;
      Left := DisplayEntry.Left - spacing - Width;
          end;

    with eTotal do
          begin
      Font.Size := DisplayQty.Font.Size;
            tw := GetWidthText('  ', Font);
      Height := DisplayQty.Height;
      Right := DisplayEntry.Left + DisplayEntry.Width;
      Width := DisplayEntry.Width + tw;
      Left := Right - Width;
      Top := StatusBar1.Top - spacing - Height;
          end;

    with POSListBox do
    begin
      Top := DisplayQty.Top + DisplayQty.Height + spacing;
      Height := eTotal.Top - spacing - Top;
      Font.Size := DisplayQty.Font.Size;
      case POSScreenSize of
        1 :
          begin
            if bLeftHanded then
              Left    := 545
            else
              Left    := 8;
          end;
        2 :
          begin
            if bLeftHanded then
              Left    := 409
            else
              Left    := 6;
          end;
        4 :
          begin
            if bLeftHanded then
              Left    := 545
            else
              Left    := 8;
          end;
      end;
      Width := DisplayEntry.Left + DisplayEntry.Width - Left;
    end;

    with lTotal do
    begin
      Font.Size := eTotal.Font.Size;
      case POSScreenSize of
      1 :
        begin
          if bLeftHanded then
            Left    := 642
          else
            Left    := 105;
          Width   := 160;
          Height  := 25;
        end;
      2 :
        begin
          if bLeftHanded then
            Left    := 482
          else
            Left    := 79;
          Width   := 120;
          Height  := 19;
        end;
      4 :
        begin
          if bLeftHanded then
            Left    := 642
          else
            Left    := 105;
          Width   := 160;
          Height  := 25;
        end;
      end;
      Top := eTotal.Top + (eTotal.Height - Height) div 2;
    end;


  end
  else
  begin
    PumpPanel.Visible := False;
    with KeyPanel do
    begin
      case POSScreenSize of
      1 :
        begin
          Top     := 3;
          if bLeftHanded then
            Left    := 5
          else
            Left    := 495;
          Width   := 525;
          Height  := 725;
        end;
      2 :
        begin
          Top     := 3;
          if bLeftHanded then
            Left    := 5
          else
            Left    := 391;
          Width   := 394;
          Height  := 544;
        end;
      4 :
        begin
          Top     := 3;
          if bLeftHanded then
            Left    := 5
          else
            Left    := 495;
          Width   := 525;
          Height  := 725;
        end;
      end;
    end;

    with lSuspend do
    begin
      case POSScreenSize of
      1 :
        begin
          Top     := 50;
          if bLeftHanded then
            Left    := 541
          else
            Left    := 4;
          Width   := 173;
          Height  := 30;
        end;
      2 :
        begin
          Top     := 38;
          if bLeftHanded then
            Left    := 406
          else
            Left    := 4;
          Width   := 130;
          Height  := 22;
          if bAutoFont then
            lSuspend.Font.Size := Round(lSuspend.Font.Size * 0.75);
        end;
      4 :
        begin
          Top     := 50;
          if bLeftHanded then
            Left    := 541
          else
            Left    := 4;
          Width   := 173;
          Height  := 30;
        end;
      end;
    end;

    with lbReturn do
    begin
      case POSScreenSize of
      1 :
        begin
          Top     := 60;
          if bLeftHanded then
            Left    := 665
          else
            Left    := 128;
          Width   := 89;
          Height  := 16;
        end;
      2 :
        begin
          Top     := 45;
          if bLeftHanded then
            Left    := 499
          else
            Left    := 96;
          Width   := 66;
          Height  := 12;
        end;
      4 :
        begin
          Top     := 60;
          if bLeftHanded then
            Left    := 665
          else
            Left    := 128;
          Width   := 89;
          Height  := 16;
        end;
      end;
    end;

    with DisplayQty do
    begin
      case POSScreenSize of
      1 :
        begin
          Top     := 50;
          if bLefthanded then
            Left    := 761
          else
            Left    := 224;
          Width   := 49;
          Height  := 30;
          Font.Size := 14;
        end;
      2 :
        begin
          Top     := 38;
          if bLefthanded then
            Left    := 570
          else
            Left    := 168;
          Width   := 36;
          Height  := 22;
          Font.Size := 10;
        end;
      4 :
        begin
          Top     := 50;
          if bLefthanded then
            Left    := 761
          else
            Left    := 224;
          Width   := 49;
          Height  := 30;
          Font.Size := 14;
        end;
      end;

    end;

    with DisplayEntry do
    begin
      case POSScreenSize of
      1 :
        begin
          Top     := 50;
          if bLeftHanded then
            Left    := 817
          else
            Left    := 280;
          Width   := 193;
          Height  := 30;
          Font.Size := 14;
        end;
      2 :
        begin
          Top     := 38;
          if bLeftHanded then
            Left    := 612
          else
            Left    := 210;
          Width   := 144;
          Height  := 22;
          Font.Size := 10;
        end;
      4 :
        begin
          Top     := 50;
          if bLeftHanded then
            Left    := 817
          else
            Left    := 280;
          Width   := 193;
          Height  := 30;
          Font.Size := 14;
        end;
      end;
    end;

    with POSListBox do
    begin
      case POSScreenSize of
      1 :
        begin
          Top     := 86;
          if bLeftHanded then
            Left    := 545
          else
            Left    := 8;
          Width   := 465;
          Height  := 500;
          Font.Size := 14;
        end;
      2 :
        begin
          Top     := 64;
          if bLeftHanded then
            Left    := 408
          else
            Left    := 6;
          Width   := 348;
          Height  := 375;
          Font.Size := 10;
        end;
      4 :
        begin
          Top     := 86;
          if bLeftHanded then
            Left    := 545
          else
            Left    := 8;
          Width   := 465;
          Height  := 500;
          Font.Size := 14;
        end;
      end;
    end;

    with lTotal do
    begin
      case POSScreenSize of
      1 :
        begin
          Top     := 600;
          if bLeftHanded then
            Left    := 642
          else
            Left    := 105;
          Width   := 160;
          Height  := 25;
          Font.Size := 14;
        end;
      2 :
        begin
          Top     := 450;
          if bLeftHanded then
            Left    := 482
          else
            Left    := 78;
          Width   := 120;
          Height  := 18;
          Font.Size := 10;
        end;
      4 :
        begin
          Top     := 600;
          if bLeftHanded then
            Left    := 642
          else
            Left    := 105;
          Width   := 160;
          Height  := 25;
          Font.Size := 14;
        end;
      end;
    end;

    with eTotal do
    begin
      case POSScreenSize of
      1 :
        begin
          Top     := 600;
          if bLefthanded then
            Left    := 817
          else
            Left    := 280;
          Width   := 193;
          Height  := 30;
          Font.Size := 14;
        end;
      2 :
        begin
          Top     := 450;
          if bLefthanded then
            Left    := 612
          else
            Left    := 210;
          Width   := 145;
          Height  := 22;
          Font.Size := 10;
        end;
      4 :
        begin
          Top     := 600;
          if bLefthanded then
            Left    := 817
          else
            Left    := 280;
          Width   := 193;
          Height  := 30;
          Font.Size := 14;
        end;
      end;
    end;

    TopKeyPos := 5 ;
    MaxKeyNo  := 88  ;  //  7 rows 8 cols + 3 special pump keys
    MaxKeyRow := 11   ;
    nBtnNo := 1;
  end;

  PPStatus.Top := eTotal.Top;
  PPStatus.Left := POSListBox.Left;

  for nRowNo := 1 to MaxKeyRow do
    for nColNo := 1 to 8 do
      begin
        BuildPOSButton(nRowNo, nColNo, nBtnNo );
        Inc(nBtnNo);
      end;


  nKybdNdx := 0;
  CreateKybdQuery(nKybdNdx, 0);
  //-  KybdQry[0].Tag := 0;

  if not POSdataMod.IBMenuTransaction.InTransaction then
    POSDataMod.IBMenuTransaction.StartTransaction;
  with POSDataMod.IBMenuQuery do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from Menu Order By MenuNo');
    Open;
    nKybdNdx := 1;
    while not EOF do
    begin
      KybdArray[nKybdNdx,0].AutoMenuClose := Boolean(FieldByName('AutoClose').AsInteger);
      CreateKybdQuery(nKybdNdx, FieldByName('MenuNo').AsInteger);
      Next;
      Inc(nKybdNdx);
    end;
    //Create placeholder menu for modifiers
    KybdArray[nKybdNdx, 0].AutoMenuClose := True;
    CreateModifierKybdQuery(nKybdNdx, 99);
    Close;
  end;
  if POSDataMod.IBMenuTransaction.InTransaction then
    POSDataMod.IBMenuTransaction.Commit;
  nKybdNdx := 0;
  for nBtnNo := 1 to MaxKeyNo do
  begin
    DisplayTouchKeys( nKybdNdx, nBtnNo ) ;
    if POSButtons[nBtnNo].KeyType = 'NMD' then
      nNextDollarKey := nBtnNo;
  end;

  nCurMenu := 0;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.BuildPOSButton
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: RowNo, ColNo, BtnNdx : short
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.BuildPOSButton(RowNo, ColNo, BtnNdx : short );
begin

  if bScreenBuilt = False then
    begin
      POSButtons[BtnNdx] := TPOSTouchButton.Create(Self);
      POSButtons[BtnNdx].Parent  := Self;
    end;

  POSButtons[BtnNdx].Name := 'PumpButton' + IntToStr(BtnNdx);
  POSButtons[BtnNdx].KeyRow      := RowNo;
  POSButtons[BtnNdx].KeyCol      := ColNo;

  case POSScreenSize of
  1 :
    begin
      POSButtons[BtnNdx].Top         := TopKeyPos + ((RowNo - 1) * 65);
      if bLeftHanded then
        POSButtons[BtnNdx].Left        := ((ColNo - 1) * 65) + 8
      else
        POSButtons[BtnNdx].Left        := ((ColNo - 1) * 65) + 500;
      POSButtons[BtnNdx].Height  := 60;
      POSButtons[BtnNdx].Width   := 60;
      POSButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
    end;
  2 :
    begin
      POSButtons[BtnNdx].Top         := TopKeyPos + ((RowNo - 1) * 50);
      if bLeftHanded then
        POSButtons[BtnNdx].Left        := ((ColNo - 1) * 50) + 8
      else
        POSButtons[BtnNdx].Left        := ((ColNo - 1) * 50) + 390;
      POSButtons[BtnNdx].Height  := 47;
      POSButtons[BtnNdx].Width   := 47;
      POSButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'BTN47');
    end;
  4 :
    begin
      POSButtons[BtnNdx].Top         := TopKeyPos + ((RowNo - 1) * 65);
      if bLeftHanded then
        POSButtons[BtnNdx].Left        := ((ColNo - 1) * 65) + 8
      else
        POSButtons[BtnNdx].Left        := ((ColNo - 1) * 65) + 500;
      POSButtons[BtnNdx].Height  := 60;
      POSButtons[BtnNdx].Width   := 60;
      POSButtons[BtnNdx].Glyph.LoadFromResourceName(HInstance, 'SMALLBTN');
    end;
  end;

  POSButtons[BtnNdx].Visible := True;
  POSButtons[BtnNdx].OnClick := POSButtonClick;
  POSButtons[BtnNdx].KeyCode     := IntToStr(RowNo) + IntToStr(ColNo);
  POSButtons[BtnNdx].FrameStyle := bfsNone;
  POSButtons[BtnNdx].WordWrap := True;
  POSButtons[BtnNdx].Tag := BtnNdx;
  POSButtons[BtnNdx].NumGlyphs := 14;
  POSButtons[BtnNdx].Frame := 8;
  POSButtons[BtnNdx].MaskColor := fmPOS.Color;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.SetPOSButtonFontColor
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: KybdNdx, BtnNdx : short
  Result:    TColor
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.SetPOSButtonFontColor(KybdNdx, BtnNdx : short ): TColor;
var
  t : longint;
begin
  if not IdentToColor(KybdArray[KybdNdx, KybdArrayNdx].BtnFontColor, t) then
  begin
    if (KybdArray[KybdNdx, KybdArrayNdx].BtnFontColor <> '') then
      UpdateExceptLog('TfmPOS.SetPOSButtonFontColor - cannot find "%s" in Graphics.Colors', [KybdArray[KybdNdx, KybdArrayNdx].BtnFontColor]);
    t := clBlack;
  end;
  SetPOSButtonFontColor := TColor(t);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.NameTheKey
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: KybdNdx, BtnNdx : integer
  Result:    string
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.NameTheKey( KybdNdx, BtnNdx : integer): string;
var
  sKeyType: string[3];
  res : string;
begin
  Res := '';
  sKeyType := Copy(KybdArray[KybdNdx, KybdArrayNdx].KeyType,1,3);
  if sKeyType = 'NUM' then
  begin
    Res := KybdArray[KybdNdx, KybdArrayNdx].KeyVal;
  end
  else if sKeyType = 'PMP' then
  begin
    Res := 'Pump# ' + KybdArray[KybdNdx, KybdArrayNdx].KeyVal;
  end
  else if sKeyType = 'MED' then
  begin
    if KybdArray[KybdNdx, KybdArrayNdx].Preset = '' then
    begin
      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      begin
        try
          Close;SQL.Clear;
          SQL.Add( 'SELECT Name FROM Media WHERE MediaNo = ' + KybdArray[KybdNdx, KybdArrayNdx].KeyVal);
          Open;
          if RecordCount = 0 then
            Res := ''
          else
            Res := FieldByName('Name').AsString;
        except
          Res := '';
        end;
        Close;
      end; {with TempQuery}
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
    end
    else
    begin
      Res := '$' + FloatToStr(StrToInt(KybdArray[KybdNdx, KybdArrayNdx].Preset) / 100);
    end;
  end
  else if sKeyType = 'PPL' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      try
        Close;SQL.Clear;
        SQL.Add( 'SELECT Name FROM Plu WHERE PluNo = ' + KybdArray[KybdNdx, KybdArrayNdx].KeyVal);
        Open;
        if RecordCount = 0 then
          Res := ''
        else
          Res := FieldByName('Name').AsString;
      except
        Res := ''
      end;
      Close;
    end; {with TempQuery}
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end
  else if sKeyType = 'DPT' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      try
        Close;SQL.Clear;
        SQL.Add( 'SELECT Name FROM Dept WHERE DeptNo = ' + KybdArray[KybdNdx, KybdArrayNdx].KeyVal);
        Open;
        if RecordCount = 0 then
          Res := ''
        else
          Res := FieldByName('Name').AsString;
      except
        Res := '';
      end;
      Close;
    end; {with TempQuery}
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end
  else if sKeyType = 'MOD' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      try
        Close;SQL.Clear;
        SQL.Add( 'SELECT ModifierName FROM Modifier WHERE ModifierGroup = ' + KybdArray[KybdNdx, KybdArrayNdx].KeyVal +
                 ' AND ModifierNo = ' + KybdArray[KybdNdx, KybdArrayNdx].Preset);
        Open;
        if RecordCount = 0 then
          Res := ''
        else
          Res := FieldByName('ModifierName').AsString;
      except
        Res := '';
      end;
      Close;
    end; {with TempQuery}
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end
  else if sKeyType = 'BNK' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      try
        Close;SQL.Clear;
        SQL.Add( 'SELECT Name FROM BankFunc WHERE BankNo = ' + KybdArray[KybdNdx, KybdArrayNdx].KeyVal);
        Open;
        if RecordCount = 0 then
          Res := ''
        else
          Res := FieldByName('Name').AsString;
      except
        Res := '';
      end;
      Close;
    end; {with TempQuery}
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end
  else if sKeyType = 'MNU' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      try
        Close;SQL.Clear;
        SQL.Add( 'SELECT Name FROM Menu WHERE MenuNo = ' + KybdArray[KybdNdx, KybdArrayNdx].KeyVal);
        Open;
        if RecordCount = 0 then
          Res := ''
        else
          Res := FieldByName('Name').AsString;
      except
        Res := '';
      end;
      Close;
    end; {with TempQuery}
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end
  else if sKeyType = 'DSC' then
  begin
    if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
    begin
      try
        Close;SQL.Clear;
        SQL.Add( 'SELECT Name FROM Disc WHERE DiscNo = ' + KybdArray[KybdNdx, KybdArrayNdx].KeyVal);
        Open;
        if RecordCount = 0 then
          Res := ''
        else
          Res := FieldByName('Name').AsString;
      except
        Res := '';
      end;
      Close;
    end; {with TempQuery}
    if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  end
  else
    Res := copy(KybdArray[KybdNdx, KybdArrayNdx].KeyType,6,20);

  if (KybdArray[KybdNdx, KybdArrayNdx].BtnLabel > '') then
    Res := KybdArray[KybdNdx, KybdArrayNdx].BtnLabel;

  NameTheKey := Res;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.GetScreenPosition
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Item, Itemcount, Width : Integer
  Result:    Integer
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.GetScreenPosition (Item, Itemcount, Width : Integer ) : Integer;
Var
 ScreenWidth     : integer;
 Spaceleft       : Integer;
 OldItemcount    : Integer;
Begin

 ScreenWidth := Screen.Width;
 OldItemcount := Itemcount;

 If Odd(Itemcount) then
   Inc(Itemcount);

 If Itemcount > Icons_Per_Line Then
   Itemcount := (Itemcount div 2);

 If Item > Itemcount Then
   Item := Item - Itemcount;

 If Not(Odd(OldItemcount)) Then
  Begin
    Spaceleft := ScreenWidth - (ItemCount * Width);              { Total Space left...   }
    Spaceleft := Round(Spaceleft / (Itemcount + 1));     { Space between Icons...}
  End
 Else
  Begin
    If Not(OldItemCount > Icons_Per_Line) Then
     Begin
      Spaceleft := ScreenWidth - ((ItemCount-1) * Width);
      Spaceleft := Round(Spaceleft / (Itemcount));
     End
    Else
     Begin
       Spaceleft := ScreenWidth - (ItemCount * Width);
       Spaceleft := Round(Spaceleft / (Itemcount + 1));
      End;
  End;

 Result := (Item * Spaceleft) +  ((Item - 1) * Width);

End;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CreatePumpIcons
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender : TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.CreatePumpIcons(Sender : TObject);
var
  NumerofPumps : Integer;
  i            : Integer;
  y            : Integer;
  MyPump       : TPumpxIcon;
begin
  y := 0;
  case POSScreenSize of
  1 :
    begin
      If No_Pumps > Icons_Per_Line Then
        y := 3
      Else
        y := 40;
    end;
  2 :
    begin
      If No_Pumps > Icons_Per_Line Then
        y := 3
      Else
        y := 30;
    end;
  4 :
    begin
      If No_Pumps > Icons_Per_Line Then
        y := 3
      Else
        y := 40;
    end;
  end;

  { We initialize some Variables for later spacing... }
  If Odd(No_Pumps) Then
    NumerofPumps := NO_PUMPS + 1
  Else
    NumerofPumps := NO_PUMPS;

  { Lets create some Pumpicons for each existing pump }
  {$IFDEF PUMP_ICON_EXT} //20080107...
  if (NO_PUMPS > 0) then
  begin
    if (POSScreenSize in [1, 4]) then
      LoadPumpFrames('PUMPICON_FRAME')
    else if (POSScreenSize = 2) then
      LoadPumpFrames('PUMPSML_FRAME');
  end;
  CalcPumpFrameMaxSize();
  {$ENDIF}  //...20080107
  For i := 1 to NO_PUMPS do
    Begin
      MyPump := TPumpxIcon.Create(Self);
      {$IFDEF PUMP_ICON_EXT}
      MyPump.PumpNo := 0;
      {$ENDIF}
      MyPump.DragMode := dmManual;
      MyPump.ButtonCaption := '';

      case POSScreenSize of
      1, 4 :
        begin
          MyPump.Height        := 116;
          MyPump.Width         := 65;
          {$IFNDEF PUMP_ICON_EXT}
          MyPump.BitMap.LoadFromResourceName(HInstance, 'PUMPICON');
          MyPump.FrameWidth := MyPump.BitMap.Width;
          MyPump.FrameHeight := MyPump.BitMap.Height;
          {$ENDIF}

          MyPump.Labelfont.size   := 10;
          MyPump.ButtonFont.size   := 12;
        end;

      2 :
        begin
          MyPump.Height        := 84;
          MyPump.Width         := 48;
          {$IFNDEF PUMP_ICON_EXT}
          MyPump.BitMap.LoadFromResourceName(HInstance, 'PUMPSML');
          MyPump.FrameWidth := MyPump.BitMap.Width;
          MyPump.FrameHeight := MyPump.BitMap.Height;
          {$ENDIF}

          MyPump.Labelfont.size   := 8;
          MyPump.ButtonFont.size   := 10;
        end;
      end;
      MyPump.Top           := y;
      MyPump.Left          := GetScreenPosition(i,NO_PUMPS,MyPump.Width);

      MyPump.Interval      := 150;
      MyPump.LabelCaption  := InttoStr(i);
      MyPump.PumpNo        := i;

      MyPump.LabelColor    := clSilver;
      MyPump.Loop          := True;
      MyPump.Name          := 'Pumpicon' + InttoStr(i);
      MyPump.Visible       := True;
      MyPump.Parent        := Self;
      MyPump.Play          := False;

      MyPump.Sound         := 0;
      MyPump.OnClick       := FuelButtonClick;
      MyPump.OnDragDrop    := FuelButtonDragDrop;
      MyPump.OnDragOver    := FuelButtonDragOver;
      MyPump.OnMouseDown   := FuelButtonMouseDown;
      MyPump.OnLongPress   := FuelButtonLongPress;

      MyPump.FrameCount    := FR_MAX;
      MyPump.Frame         := FR_COMMDOWN;
      MyPump.IdleFrame     := FR_IDLENOCAT;
      MyPump.ButtonFont.Color  := clBlack;
      MyPump.ClearSale1;
      MyPump.ClearSale2;


      MyPump.CardType      := 0;
      MyPump.PumpOnLine    := False;
      MyPump.CATHintTimeout  := Setup.CATHintTimeout;
      MyPump.CATHintInterval := Setup.CATHintInterval;

      if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
      with POSDataMod.IBTempQuery do
      Begin
        Close;SQL.Clear;
        SQL.Add('SELECT * from PumpDef where HoseNo = 1 and PumpNo = ' + IntToStr(i));
        Open;
        MyPump.CATEnabled := False;
        MyPump.CATOnLine  := False;
        if not EOF then
        Begin
          if Boolean(FieldbyName('CATHead').AsInteger) = True then
          Begin
            MyPump.CATEnabled := True;
          End;
        End;
        Close;
      end;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;

      if NO_PUMPS > Icons_Per_Line Then    { We will have to split... }
        Begin
          If i = (NumerofPumps div 2) Then
            y := y + MyPump.Height + 3;
        End;

        nPumpIcons[i] := MyPump;

    End;
End;

procedure TfmPOS.SetupDevice(DeviceType : integer);
var
  nDeviceType, nDeviceNo, nDriver, nPort, nData, nStop: short;
  nBaud    : integer;
  nParity  : TParity;
  OPOSName : string;
begin
 UpdateZLog('inside  TfmPOS.SetupDevice function-tarang');
  //ShowMessage('inside  TfmPOS.SetupDevice function'); // madhu remove
  if not POSDataMod.IBSetPortQry.Transaction.InTransaction then
    POSDataMod.IBSetPortQry.Transaction.StartTransaction;
  UpdateZLog('TfmPOS.SetupDevice: Starting IBSetPortQry');
  with POSDataMod.IBSetPortQry do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from TermPorts where TerminalNo = :pTerminalNo and DeviceType = :pDeviceType');
      ParamByName('pTerminalNo').AsInteger := ThisTerminalNo;
      ParamByName('pDeviceType').AsInteger := DeviceType;
      Open;
      while NOT eof do
        begin
          nDeviceType := FieldByName('DeviceType').AsInteger;
          nDeviceNo := FieldByName('DeviceNo').AsInteger;
          nDriver := FieldByName('Driver').AsInteger;
          OPOSName := FieldByName('OPOSName').AsString;
          nPort := FieldByName('PortNo').AsInteger;
          nBaud := FieldByName('BaudRate').AsInteger;
          nData := FieldByName('DataBits').AsInteger;
          nStop := FieldByName('StopBits').AsInteger;
          if FieldByName('Parity').AsInteger = 0 then
            nParity := pNone
          else if FieldByName('Parity').AsInteger = 1 then
            nParity := pEven
          else
            nParity := pOdd;
          UpdateZLog('TfmPOS.SetupDevice: Calling AssignPorts for COM' + IntToStr(nPort));
          AssignPorts(nDeviceType, nDeviceNo, nDriver, nPort, nBaud, nData, nStop, nParity, OPOSName);
          next;
        end;
      Close;
    end;
  POSDataMod.IBSetPortQry.Transaction.Commit;
  UpdateZLog('TfmPOS.SetupDevice: Committed IBSetPortQry transaction');
  fmPOSMsg.Close();
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.SetupPorts
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.SetupPorts;
var

  i: Integer;
  nDeviceType, nDeviceNo, nDriver, nPort, nData, nStop: short;
  nBaud         : integer;
  nParity       : TParity;
  OPOSName : string;

begin
  if not POSDataMod.IBSetPortQry.Transaction.InTransaction then
    POSDataMod.IBSetPortQry.Transaction.StartTransaction;
  UpdateZLog('TfmPOS.SetupPorts: Starting IBSetPortQry');
  with POSDataMod.IBSetPortQry do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from TermPorts where TerminalNo = ' + IntToStr(ThisTerminalNo));
      Open;
      while NOT eof do
        begin
          nDeviceType := FieldByName('DeviceType').AsInteger;
          nDeviceNo := FieldByName('DeviceNo').AsInteger;
          nDriver := FieldByName('Driver').AsInteger;
          OPOSName := FieldByName('OPOSName').AsString;
          nPort := FieldByName('PortNo').AsInteger;
          nBaud := FieldByName('BaudRate').AsInteger;
          nData := FieldByName('DataBits').AsInteger;
          nStop := FieldByName('StopBits').AsInteger;
          if FieldByName('Parity').AsInteger = 0 then
            nParity := pNone
          else if FieldByName('Parity').AsInteger = 1 then
            nParity := pEven
          else
            nParity := pOdd;
          UpdateZLog('TfmPOS.SetupPorts: Calling AssignPorts for COM' + IntToStr(nPort));
          AssignPorts(nDeviceType, nDeviceNo, nDriver, nPort, nBaud, nData, nStop, nParity, OPOSName);
          next;
        end;
      Close;
    end;
  POSDataMod.IBSetPortQry.Transaction.Commit;
  UpdateZLog('TfmPOS.SetupPorts: Committed IBSetPortQry transaction');


    if (bPoleActive > 0) and (Boolean(Setup.ScrollOn) = True) then
      begin
        case bPoleActive of
        1 :
          begin
            BlankPole;
            nScrollPtr := 21;
            sScrollMess := Setup.ScrollMess + ' ';
            nScrollSize := Length(sScrollMess);

            for i := nScrollSize to 21 do      // Pad Out to at Least 21 chars
              sScrollMess := sScrollMess + ' ';

            nScrollSize := Length(sScrollMess);
            sScrollBuff :=  #16#19#32#16#0 + copy(sScrollMess,1,20);

            bScrollMessOn     := True;
            bScrollMessActive := True;
          end;
        2 :
          begin
            BlankPole;
            nScrollPtr := 21;
            sScrollMess := Setup.ScrollMess + ' ';
            nScrollSize := Length(sScrollMess);

            for i := nScrollSize to 21 do      // Pad Out to at Least 21 chars
              sScrollMess := sScrollMess + ' ';

            nScrollSize := Length(sScrollMess);
            sScrollBuff :=  #16#19#32#16#0 + copy(sScrollMess,1,20);

            bScrollMessOn     := True;
            bScrollMessActive := True;
          end;

        end;
      end
    else
     Begin
   //   BlankPole;
      bScrollMessOn     := False;
      bScrollMessActive := False;
     End;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.AssignPorts
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: nDeviceType, nDeviceNo, nDriver, nPort, nBaud, nData, nStop : integer; nParity : TParity; OPOSName : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.AssignPorts(nDeviceType, nDeviceNo, nDriver, nPort, nBaud, nData, nStop : integer;
              nParity : TParity; OPOSName : string );
var
iParity : integer;
//cwe...
//i, TryCount : integer;
  TryCount : integer;
  devname : string;
  startts : TDateTime;
  wr : TWaitResult;
  i, found : integer;
begin
  UpdateZLog('TfmPOS.AssignPorts - starting - Device Type: ' + IntToStr(nDeviceType));
  UpdateZLog(Format('TfmPOS.AssignPorts - Attempting connection to Port %d at baud %d with %d bits, %d stop bits, %s parity',[nPort, nBaud, nData, nStop, ParityName[nParity]]));
  try
    case nDeviceType of
      1 : begin
            devname := 'Printer';
            fmPOSMsg.ShowMsg('Initializing Printer...', '');

            if nParity = pNone then
              iParity := 0
            else if nParity = pEven then
              iParity := 1
            else
              iParity := 2;

            for TryCount := 1 to 5 do
            begin
              try
                if DCOMPrinter = nil then
                begin
                  DCOMPrinter := CoTReceipt.Create;
                  if (ReceiptEvents <> NIL) then ReceiptEvents.Free;
                  ReceiptEvents := TReceiptSrvrITReceiptEvents.Create (Self);
                  ReceiptEvents.GotPrinterError := ReceiptEventsGotPrinterError;
                  ReceiptEvents.Connect (DCOMPrinter);
                  DCOMPrinter.InitPrinter(nDeviceNo, nDriver, nPort, nBaud, nData, nStop, iParity, OPOSName, ExtractFileDir(Application.ExeName) + '\' + Setup.PrtLogoName);
                  break;
                end
                else
                  try
                    if (ReceiptEvents <> NIL) then ReceiptEvents.Free;
                    ReceiptEvents := TReceiptSrvrITReceiptEvents.Create (Self);
                    ReceiptEvents.GotPrinterError := ReceiptEventsGotPrinterError;
                    ReceiptEvents.Connect (DCOMPrinter);
                    DCOMPrinter.InitPrinter(nDeviceNo, nDriver, nPort, nBaud, nData, nStop, iParity, OPOSName, ExtractFileDir(Application.ExeName) + '\' + Setup.PrtLogoName);
                    break;
                  except
                  end;
              except
                on E: Exception do
                begin
                  UpdateExceptLog('Init Printer Try ' + IntToStr(TryCount) );
                  DCOMPrinter := nil;
                end;
              end;
            end;
            PtrDeviceNo := nDeviceNo;
            PtrDriver := nDriver;
            PtrPort := nPort;
            PtrBaud := nBaud;
            PtrData := nData;
            PtrStop := nStop;
            PtrParity := iParity;
            PtrOPOSName := OPOSName;
            bReceiptActive := nDriver;

          end;
      2 : begin
            if PolePort = nil then
            begin
              PolePort := TApdComPort.Create(Self);
            end;
            devname := 'Pole Display';
            fmPOSMsg.ShowMsg('Initializing Pole Display...', '');
            case nDriver of
              1 : ComSetup(PolePort,nPort,nBaud,nData,nStop,nParity,True);
              2 :
                begin
                  OPOSPoleDisplay.Open(OPOSName);
                  OPOSPoleDisplay.ClaimDevice(0);
                  OPOSPoleDisplay.DeviceEnabled := True;
                end;
            end;
            bPoleActive := nDriver;
            iPoleType   := nDeviceNo;
          end;
      3 : begin
            devname := 'Scanner';
            fmPOSMsg.ShowMsg('Initializing Scanner...', '');
            case nDriver of
              1 :
                begin
                  found := -1;
                  if length(scannerports) > 0 then
                    for i := 0 to pred(length(scannerports)) do
                      if (scannercomports[i] = nPort) then
                        found := i;
                  if found < 0 then
                  begin
                    i := length(scannerports);
                    setlength(scannerports, i+1);
                    setlength(scannercomports, i+1);
                    ScannerPorts[i] := Scanner.GetScanner(fmPos, nDeviceNo);
                    ScannerPorts[i].PortSettings(nPort,nBaud,nData,nStop,nParity);
                    ScannerPorts[i].OnDataEvent := fmPOS.ScannerPortDataEvent;
                  end
                  else
                    i := found;
                  ScannerPorts[i].Open := True;
                  StartTS := Now;
                  while not ScannerPorts[i].Online and not TimerExpired(StartTs, 3) do
                    Application.ProcessMessages;
                end;
              2 :
                begin
                  OPOSScanner.Open(OPOSName);
                  OPOSScanner.ClaimDevice(0);
                  OPOSScanner.DeviceEnabled := True;
                  OPOSScanner.DataEventEnabled := True;
                end;
            end;
            bScannerActive := nDriver;
          end;

      5 : begin
            if PriceSignPort = nil then
            begin
              PriceSignPort := TApdComPort.Create(Self);
              PriceSignPort.OnTriggerAvail := Self.PriceSignPortTriggerAvail;
            end;
            devname := 'Price Sign';
            fmPOSMsg.ShowMsg('Initializing Price Sign...', '');
            ComSetup(PriceSignPort,nPort,nBaud,nData,nStop,nParity,True);
            bPriceSignActive        := 1;
          end;

      6 : begin
            devname := 'MSR';
            fmPOSMsg.ShowMsg('Initializing MSR...', '');
            case nDriver of
              1 : begin
                    if not assigned(MSRPort) then
                    begin
                      MSRPort := MSR.GetMSR(fmPos, nDeviceNo);
                      MSRPort.PortSettings(nPort,nBaud,nData,nStop,nParity);
                      MSRPort.OnDataEvent := Self.MSRPortDataEvent;
                      MSRPort.Logging := False;
                    end;
                    MSRPort.Open := True;
                  end;
            end;
            bMSRActive := nDriver;
          end;

      7 : begin
            devname := 'PIN Pad';
            fmPOSMsg.ShowMsg('Initializing PIN Pad...', '');

            if (nDeviceNo = 30) then  // Ingenico
            begin
              if (PPTrans = nil) then
              begin
                PPTrans := TPINPadTrans.Create(Self);
                PPTrans.Showmsg := fmPOSMsg.ShowMsg;
                PPTrans.onCardInfoReceived := PPCardInfoReceived;
                PPTrans.onAuthInfoReceived := PPAuthInfoReceived;
                PPTrans.OnCardStatusChange := fmNBSCCForm.PPCardStatusChange;
                PPTrans.OnSignatureReceived := Self.PPSigReceived;
                PPTrans.OnPinPadPromptChange := PPPromptChange;
                PPTrans.OnSwipeChange := OnPinPadSwipeChange;
                PPStatus.Enabled := True;
                PPStatus.Visible := True;
                PPTrans.OnOnlineChange := Self.PPOnlineChange;
                PPTrans.OnPinPadAdQuery := AdManageMod.GetAdNo;
                PPTrans.OnAdMaxChange := AdManageMod.SetMaxAd;
                PPTrans.OnCustomerDataReceived := Self.PPCustomerDataReceived;
                PPTrans.OnSerialNoChange := self.PPSerialNoChanged;
                PPTrans.Store := StrToInt(Setup.NUMBER);
                PPTrans.Reg := Self.ThisTerminalNo;
                PPTrans.CCSendMsg := Self.CCSendMsg;
                try
                  PPTrans.EnableContactless := fmPOS.Config.Bool['PP_ENABLECONTACTLESS']
                except
                  on E: EKeyError do PPTrans.EnableContactless := False;
                  on E: Exception do
                    UpdateZLog('Problem with PP_ENABLECONTACTLESS in config - %s - %s', [E.ClassName, E.Message]);
                end;
                try
                  PPTrans.EMVEnabled := fmPOS.Config.Bool['PP_ENABLEEMV']
                except
                  on E: EKeyError do PPTrans.EMVEnabled := False;
                  on E: Exception do
                    UpdateZLog('Problem with PP_ENABLEEMV in config - %s - %s', [E.ClassName, E.Message]);
                end;
                try
                  PPTrans.AdServerURL := fmPOS.Config.Str['PP_ADSERVERURL'];
                except
                  on E: EKeyError do begin end;
                  on E: Exception do
                    UpdateZLog('Problem with PP_ADSERVERURL in config - %s - %s', [E.ClassName, E.Message]);
                end;
                Self.FPinPadOnlineEvent := TEvent.Create(nil, True, False, 'PinPadOnline');
              end;
              try
                PPTrans.Enabled := fmPOS.Config.Bool['PP_ENABLED'];
              except
                on E: EKeyError do PPTrans.Enabled := True;
                on E: Exception do
                begin
                  UpdateZLog('Problem with PP_ENABLED boolean in config - %s - %s', [E.ClassName, E.Message]);
                  PPTrans.Enabled := True;
                end;
              end;

              try
                PPTrans.LoadFileDir := fmPOS.Config.Str['PP_DIR'];
              except
                PPTrans.LoadFileDir := '\Latitude\Update\Ingenico\';
              end;
              if PPTrans.PinPadOnLine then
              begin
                PPTrans.PINPadClose;
                StartTS := Now();
                repeat
                  Application.ProcessMessages;
                  wr := Self.FPinPadOnlineEvent.WaitFor(10);
                until (wr = wrTimeout) or TimerExpired(StartTS, 15);
                end;
                PPTrans.PinPadCreditSignatureLimit := fmPOS.Config.Cur['CC_SIGNATURE_LIMIT'];
                try
                  PPTrans.ReqApplId := fmPOS.Config.Str['PP_REQ_APPL_ID'];
                except
                  on E: EKeyError do PPTrans.ReqApplId := '0000';
                  on E: Exception do
                    begin
                      PPTrans.ReqApplId := '0000';
                      UpdateExceptLog('Problem setting Required Application ID - ' + E.Message);
                    end;
                end;
                try
                  PPTrans.ReqParmId := fmPOS.Config.Str['PP_REQ_PARM_ID'];
                except
                  on E: EKeyError do PPTrans.ReqParmId := '0000';
                  on E: Exception do
                    begin
                      PPTrans.ReqParmId := '0000';
                      UpdateExceptLog('Problem setting Required Parameter ID - ' + E.Message);
                    end;
                end;
                PPTrans.PinPadPortNo       := nPort;
                PPTrans.PinPadBaudRate     := nBaud;
                PPTrans.PinPadDataBits     := nData;
                PPTrans.PinPadStopBits     := nStop;
                PPTrans.PinPadParity       := nParity;
                PPTrans.PaymentTypes(fmPos.bDebitAllowed, True, fmPos.bEBTCBAllowed, fmPos.bEBTFSAllowed, fmPos.bGiftAllowed);
                PPTrans.LoggingEnabled := bPPLogging;
                     // madhu gv  27-10-2017
                try
                  PPTrans.AdWaitPeriod := fmPOS.Config.Int['PP_ADWAIT_PERIOD'];
                except
                  on E: EKeyError do PPTrans.AdWaitPeriod := 4;
                  on E: Exception do
                    begin
                      UpdateExceptLog('Problem setting Ad Wait Period - ' + E.Message);
                      PPTrans.AdWaitPeriod := 4;
                    end;
                end;
                try
                  PPTrans.AdCheckPeriod := fmPOS.Config.Int['PP_ADCHECK_PERIOD'];
                except
                  on E: EKeyError do PPTrans.AdCheckPeriod := 30;
                  on E: Exception do
                    begin
                      UpdateExceptLog('Problem setting Ad Check Period - ' + E.Message);
                      PPTrans.AdCheckPeriod := 30;
                    end;
                end;
                try
                  PPTrans.AdDisplayPeriod := fmPOS.Config.Int['PP_ADDISPLAY_PERIOD'];
                except
                  on E: EKeyError do PPTrans.AdDisplayPeriod := 0;
                  on E: Exception do
                    begin
                      UpdateExceptLog('Problem setting Ad Display Period - %s', [E.Message]);
                      PPTrans.AdDisplayPeriod := 0;
                    end;
                end;

                PPTrans.PINPadOpen();
                
                
                StartTS := Now();
                repeat
                  Application.ProcessMessages;
                  wr := Self.FPinPadOnlineEvent.WaitFor(10);
                until (wr = wrSignaled) or TimerExpired(StartTS, 10);
                if wr = wrSignaled then
                begin
                  PPTrans.PINPadTransReset();
                end;
              end;
            end;

  8 : begin
            devname := 'Drawer';
            fmPOSMsg.ShowMsg('Initializing Drawer...', '');
            if nParity = pNone then
              iParity := 0
            else if nParity = pEven then
              iParity := 1
            else
              iParity := 2;

            for TryCount := 1 to 5 do
            begin
              try
                if DCOMPrinter = nil then
                begin
                  DCOMPrinter := CoTReceipt.Create;
                  if (ReceiptEvents <> NIL) then
                  begin
                    ReceiptEvents.Disconnect;
                    ReceiptEvents.Free;
                  end;
                  ReceiptEvents := TReceiptSrvrITReceiptEvents.Create (Self);
                  ReceiptEvents.GotPrinterError := ReceiptEventsGotPrinterError;
                  ReceiptEvents.Connect (DCOMPrinter);
                  DCOMPrinter.InitDrawer(nDeviceType, nDriver, nPort, nBaud, nData, nStop, iParity, OPOSName);
                  break;
                end
                else
                  try
                    if (ReceiptEvents <> NIL) then
                    begin
                      ReceiptEvents.Disconnect;
                      ReceiptEvents.Free;
                    end;
                    ReceiptEvents := TReceiptSrvrITReceiptEvents.Create (Self);
                    ReceiptEvents.GotPrinterError := ReceiptEventsGotPrinterError;
                    ReceiptEvents.Connect (DCOMPrinter);
                    DCOMPrinter.InitDrawer(nDeviceType, nDriver, nPort, nBaud, nData, nStop, iParity, OPOSName);
                    break;
                  except
                  end;
              except
                on E: Exception do
                begin
                  UpdateExceptLog('Init Drawer Try ' + IntToStr(TryCount) );
                  DCOMPrinter := nil;
                end;
              end;
            end;
            DwrDeviceType := nDeviceType;
            DwrDriver := nDriver;
            DwrPort := nPort;
            DwrBaud := nBaud;
            DwrData := nData;
            DwrStop := nStop;
            DwrParity := iParity;
            DwrOPOSName := OPOSName;

            bCashDrawerActive := nDriver;
          end;
      9 : begin
            if CoinPort = nil then
            begin
              CoinPort := TApdComPort.Create(Self);
              //CoinPort.OnTriggerAvail :=
            end;
            devname := 'Coin Changer';
            fmPOSMsg.ShowMsg('Initializing Coin Changer...', '');
            case nDriver of
              1 : ComSetup(CoinPort,nPort,nBaud,nData,nStop,nParity,True);
              2 :
                begin
                end;
            end;
            bCoinDispenserActive := nDriver;
          end;
      10: begin
            if not assigned(ScalePort) then
            begin
              UpdateZLog('Opening Scale port');
              ScalePort := TApdComPort.Create(Self);
            end;
            ComSetup(ScalePort, nPort, nBaud, nData, nStop, nParity, True);
            if not assigned(Scale) then
            begin
              Scale := TScale.Create();
              Scale.Port := ScalePort;
              UpdateZLog('Created Scale object');
            end;
          end;
      99: begin
            if InjectionPort = nil then
            begin
              InjectionPort := TApdComPort.Create(Self);
              InjectionPort.OnTriggerAvail := InjectionPortTriggerAvail;
            end;
            devname := 'Injection system';
            fmPOSMsg.ShowMsg('Initializing Injection System...', '');
            ComSetup(InjectionPort, nPort,nBaud,nData,nStop,nParity,True);
          end;

    end;
  except
    on E: Exception do
    begin
      POSError('Problem Initializing ' + devname + ' - Call Support');
      UpdateExceptLog('POSMain.AssignPorts - Problem initializing ' + devname + ': ' + E.Message);
      POSMenu.AppException(Self, E);
    end;
  end;
  UpdateZLog('TfmPOS.AssignPorts - Exiting');
end;

procedure TfmPOS.ConnectMCP;
begin
  if not assigned(MCPTCPClient) then
  try
    MCPTCPClient := TIdTCPClient.Create(Self);
    MCPTCPClient.Port := 7110;
    MCPTCPClient.Host := MCPHost;
    MCPTCPClient.OnConnected := Self.MCPConnected;
    MCPTCPClient.OnDisconnected := Self.MCPDisconnected;
    MCPTCPClient.Name := 'MCPTCPClient';
    UpdateExceptLog('Attempting connection to MCP Server (%s, %d)', [MCPTCPClient.Host, MCPTCPClient.Port]);
    UpdateZLog('Attempting connection to MCP Server (%s, %d)', [MCPTCPClient.Host, MCPTCPClient.Port]);
    MCP := TTagTCPClient.Create(MCPTCPClient, format('REG%d', [ThisTerminalNo]),AnsiReplaceStr(GetBuildInfoString(), 'Ver: ', ''), cipherlist);
    MCP.OnRecv := Self.MCPMsgRecv;
    MCP.OnExceptLog := Self.MCPLog;
    MCP.OnLog := Self.MCPLog;
    MCP.Resume;
  except
    on E: Exception do
    begin
      ShowMessage ('Error connecting to MCPServer Reason: ' + E.Message);
      FreeAndNil(MCP);
      FreeAndNil(MCPTCPClient);
    end;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ConnectFuelServer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ConnectFuelServer;
begin
  try
    nFuelInterfaceType := Setup.FuelInterfaceType;
    nCATInterfaceType  := Setup.CATInterfaceType;
  except
    nFuelInterfaceType := 1;
    nCATInterfaceType  := 0;
  end;
  if (nFuelInterfaceType < 1) or (nFuelInterfaceType > 2) then
    nFuelInterfaceType := 1;
  if (ThisTerminalNo = MasterTerminalNo) and (fuelhost = 'localhost') and not CheckRunning('FuelProg.exe') then
    StartProcess('\Latitude\FuelProg.exe');
  if (True) then
  begin
    if not assigned(FuelTCPClient) then
    try
      FuelTCPClient := TIdTCPClient.Create(Self);
      FuelTCPClient.Port := 7112;
      FuelTCPClient.Host := FuelHost;
      FuelTCPClient.OnConnected := Self.FuelConnected;
      FuelTCPClient.OnDisconnected := Self.FuelDisconnected;
      FuelTCPClient.Name := 'FuelTCPClient';
      UpdateExceptLog('Attempting connection to Fuel Server (%s, %d)', [FuelTCPClient.Host, FuelTCPClient.Port]);
      UpdateZLog('Attempting connection to Fuel Server (%s, %d)', [FuelTCPClient.Host, FuelTCPClient.Port]);
      Fuel := TTagTCPClient.Create(FuelTCPClient, format('REG%d', [ThisTerminalNo]), AnsiReplaceStr(GetBuildInfoString(), 'Ver: ', ''), cipherlist);
      Fuel.OnRecv := Self.FuelMsgRecv;
      Fuel.OnExceptLog := Self.FuelLog;
      Fuel.OnLog := Self.FuelLog;
      Fuel.Resume;
      //SendFuelMessage(0, FS_STARTSERVER, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
    except
      on E: Exception do
      begin
        ShowMessage ('Error connecting to FuelServer Reason: ' + E.Message);
        FreeAndNil(Fuel);
        FreeAndNil(FuelTCPClient);
      end;
    end;
  end;
end;

procedure TfmPOS.FuelConnected(Sender : TObject);
begin
  UpdateZLog('Connected to Fuel Server');
  if ThisTerminalNo = MasterTerminalNo then
    SendFuelMessage(0, PMP_RESUMEALL, NOAMOUNT, NOSALEID, NOTRANSNO, NODESTPUMP );
  FuelStatus.Status := tisOK;
end;

procedure TfmPOS.FuelDisconnected(Sender : TObject);
var
  i : integer;
  outdata : pMsgData;
  reason : string;
begin
  FuelStatus.Status := tisNotOK;
  reason := '';
  if Sender is Exception then
    reason := Exception(Sender).Message
  else
    reason := Sender.ClassName;
  UpdateZLog('Disconnected from Fuel Server %s', [reason]);
  if no_pumps > 0 then
  begin
    for i := 1 to NO_Pumps do
    begin
      new(outdata);
      outdata^.Orig := 'FuelSrvr';
      outdata^.Msg := BuildTag(FSTAG_PUMPACTION, IntToStr(PMP_COMMDOWN)) + BuildTag(FSTAG_PUMPNO, IntToStr(i));
      outdata^.TerminalNo := ThisTerminalNo;
      FSList.Add(outdata);
      PostMessage(fmPOS.Handle, WM_FSMSG, 0, 0);
    end;
  end;
end;

procedure TfmPOS.FuelLog(Sender : TObject; logmsg : string);
begin
  UpdateZLog('FuelThread - %s', [logmsg]);
end;

procedure TfmPOS.FuelMsgRecv(Sender : TObject; msg : string);
var
  OutData : pMsgData;
begin
  if GetTagData(FSTAG_PUMPACTION, Msg) <> '' then
  begin
    if bFuelMsgLogging then
      UpdateZLog('FuelMsgRecv: %s', [DeformatFuelMsg(Msg)]);
    New(OutData);
    OutData^.Orig := 'FuelSrvr';
    OutData^.Msg := Msg;
    OutData^.TerminalNo := ThisTerminalNo;
    FSList.Add(OutData);
    PostMessage(fmPOS.Handle,WM_FSMSG,0,0);
  end;
end;

procedure TfmPOS.CreditConnected(Sender : TObject);
begin
  if ThisTerminalNo = MasterTerminalNo then
  begin
        SendCreditMessage(BuildTag(TAG_MSGTYPE, IntToStr(CC_RESUMECREDIT)));
  end;
  CreditStatus.Status := tisOK;
end;

procedure TfmPOS.CreditDisconnected(Sender : TObject);
begin
  CreditStatus.Status := tisNotOK;
  UpdateZLog('Disconnected from Credit Server');
end;

procedure TfmPOS.CreditLog(Sender : TObject; logmsg : string);
begin
  UpdateZLog('CreditThread - %s', [logmsg]);
end;

procedure TfmPOS.CreditMsgRecv(Sender : TObject; msg : string);
var
  OutCCData : pCCData;
begin
   UpdateZLog(msg);
  //ShowMessage('inside TfmPOS.CreditMsgRecv function'); // madhu remove
  New(OutCCData);
  OutCCData^.Orig := 'CrdtSrvr';
  OutCCData^.Msg := Msg;
  OutCCData^.TerminalNo := ThisTerminalNo;
  CCList.Add(OutCCData);
  PostMessage(fmPOS.Handle,WM_CCMSG,0,0);
end;

procedure TfmPOS.MCPConnected(Sender : TObject);
begin
  UpdateZLog('Connected to MCP Server');
  MCPStatus.Status := tisOK;
end;

procedure TfmPOS.MCPDisconnected(Sender : TObject);
begin
  MCPStatus.Status := tisNotOK;
  UpdateZLog('Disconnected from MCP Server');
end;

procedure TfmPOS.MCPLog(Sender : TObject; logmsg : string);
begin
  UpdateZLog('MCPThread - %s', [logmsg]);
end;

procedure TfmPOS.CompleteLogon(var Msg: TMessage);
var
  pclr : pCompleteLogonRec;
begin
  if msg.wparam <> 0 then
  begin
    pclr := pCompleteLogonRec(msg.wparam);
    try
      if fmUser.Visible then
        fmUser.CompleteLogon(pclr.bAlreadyLoggedOn, pclr.bSupportAlreadyLoggedOn, pclr.OnTerminal)
      else
        UpdateExceptLog('TfmPOS.MCPMsgRecv (logon info response) - No Logon Screen ');
    finally
      Dispose(pclr);
    end;
  end
  else
    UpdateExceptLog('TfmPOS.CompleteLogon - parameter not assigned, cannot handle');
end;

procedure TfmPOS.MCPMsgRecv(Sender : TObject; msg : string);
var
  msgtype : integer;
  LUSeqNo : integer;
  ResumeMode : TResumeKeyMode;
  pclr : pCompleteLogonRec;
begin
  UpdateZLog('MCPMsgRecv %s', [DeformatMCPMsg(msg)]);
  msgtype := StrToInt(GetTagData(TAG_MSGTYPE, Msg));
  if (msgtype = MCP_LOGGED_ON_INFO_RESP) then
  begin
    // Response from user server (response to request to see who all is already logged in)
    LUSeqNo := StrToInt(GetTagData(MCP_LU_SEQNO, Msg));
    if (LUSeqNo = LU_RET_LOGON) then
    begin
      new(pclr);
      pclr.bAlreadyLoggedOn := TextToBool(GetTagData(MCP_LU_ALREADY_LOGGED_ON, Msg));
      pclr.bSupportAlreadyLoggedOn := TextToBool(GetTagData(MCP_LU_SUPPORT_LOGGED_ON, Msg));
      pclr.OnTerminal := StrToIntDef(GetTagData(MCP_LU_OTHER_TERMINAL_NO, Msg),0);
      // Complete logon attempt (that started by queing a request to see who else is logged on).
      PostMessage(fmPOS.Handle,WM_COMPLETELOGON, longint(pclr), 0);
    end
    else
    begin
      // Resume the procedure that exited after queuing a request to see if others are logged on:
      if (TextToBool(GetTagData(MCP_LU_OTHERS_LOGGED_ON, Msg))) then
        ResumeMode := mResumeKeyTerminalNotClosed
      else
        ResumeMode := mResumeKeyTerminalClosed;
      case LUSeqNo of
        LU_RET_BAR, LU_RET_ASU, LU_RET_EOD, LU_RET_EOS :  PostMessage(fmPOS.Handle,WM_PREPROCESSKEY, LUSeqNo,ord(ResumeMode));
      else
        UpdateExceptLog('TfmPOS.MCPMsgRecv (logon info response) - Invalid SeqNo = ' + IntToStr(LUSeqNo) + ' - Msg = "' + Msg + '"');
      end;   {end case}
    end;
    exit;
  end
  else if (msgtype = MCP_GET_USERID) then
  begin
    SendUserID(Msg);
    exit;
  end
  else if (msgtype = MCP_PUSHED_EOD_DATA) then
  begin
    fPushedEOD := False;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.SendMCPMessage
  Author:
  Date:
  Arguments: Msg : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.SendMCPMessage(Msg : string);
var
  TryCount : integer;
begin
  if NOT bClosingPOS then
  begin
    for TryCount := 1 to 5 do
    begin
      try
        UpdateZLog('SendMCPMessage - %s', [DeformatMCPMsg(Msg)]);
        MCP.SendMsg(Msg);
        break;
      except
        on E: Exception do
          UpdateExceptLog('POS SendMCPMessage failed %s - %s', [e.message, Msg]);
      end;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ConnectCreditServer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ConnectCreditServer;
begin
 UpdateZLog('inside TfmPOS.ConnectCreditServer function-tarang');
 //ShowMessage('inside TfmPOS.ConnectCreditServer function'); // madhu remove
  try
    nCreditAuthType := Setup.CreditAuthType ;
  except
    nCreditAuthType := 1;
  end;
  if (ThisTerminalNo = MasterTerminalNo) and (credithost = 'localhost') and not CheckRunning('CreditServer.exe') then
    StartProcess('\Latitude\CreditServer.exe');
  if (CreditHostReal(nCreditAuthType)) then
  begin
    if not assigned(CreditDefs) then
    begin
      CreditDefs := TStringList.Create();
      CreditDefs.Sorted := True;
    end;
    if not assigned(CreditTCPClient) then
    try
      CreditTCPClient := TIdTCPClient.Create(Self);
      CreditTCPClient.Port := 7111;
      CreditTCPClient.Host := CreditHost;
      CreditTCPClient.OnConnected := Self.CreditConnected;
      CreditTCPClient.OnDisconnected := Self.CreditDisconnected;
      CreditTCPClient.Name := 'CreditTCPClient';
      UpdateZLog('Attempting connection to Credit Server (%s, %d)', [CreditTCPClient.Host, CreditTCPClient.Port]);
      Credit := TTagTCPClient.Create(CreditTCPClient, format('REG%d', [ThisTerminalNo]), AnsiReplaceStr(GetBuildInfoString(), 'Ver: ', ''), cipherlist);
      Credit.OnRecv := Self.CreditMsgRecv;
      Credit.OnExceptLog := Self.CreditLog;
      Credit.OnLog := Self.CreditLog;
      Credit.Resume;
    except
      on E: Exception do
      begin
        ShowMessage ('Error connecting to CreditServer Reason: ' + E.Message);
        FreeAndNil(Credit);
        FreeAndNil(CreditTCPClient);
      end;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ConnectCarWashServer
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ConnectCarWashServer();
var
StartMsg : string;
begin
  case Setup.CarWashInterfaceType of
  1 : ;
  CWSRV_UNITEC, CWSRV_PDQ :
    begin
      try
        begin
          if DCOMCarwash = nil then
          begin
            if MasterTerminalNo = ThisTerminalNo then
              //DCOMCarwash := CoTCarwash.Create
              DCOMCarwash := CoCarwashOLE.Create
            else
              DCOMCarwash := CoCarwashOLE.CreateRemote(MasterTerminalUNCName);//CoTCarwash.CreateRemote(MasterTerminalUNCName);
            if (CarwashEvents <> NIL) then
            begin
              CarwashEvents.Disconnect;
              CarwashEvents.Free;
            end;
//            CarwashEvents := TCarWashSrvrICarWashEvents.Create (Self);
//            CarwashEvents.GotMsgEvent := CarwashEventsGotMsgEvent;
            CarwashEvents := TCarwashICarwashOLEEvents.Create(Self);
            CarwashEvents.GotMsg := CarwashEventsGotMsg;
            CarwashEvents.Connect (DCOMCarwash);
          end
          else
          try
            if (CarwashEvents <> NIL) then
            begin
              CarwashEvents.Disconnect;
              CarwashEvents.Free;
            end;
//            CarwashEvents := TCarwashSrvrICarwashEvents.Create (Self);
//            CarwashEvents.GotMsgEvent := CarwashEventsGotMsgEvent;
            CarwashEvents := TCarwashICarwashOLEEvents.Create(Self);
            CarwashEvents.GotMsg := CarwashEventsGotMsg;
            CarwashEvents.Connect (DCOMCarwash);
          except
          end;
        end;
      except
        on E: Exception do
          begin
            ShowMessage ('Error connecting to DCOM Car Wash Application Client' + #10#13+ 'Reason: ' + E.Message);
            DCOMCarWash := nil;
            CarwashEvents := nil;
          end;
      end;
    end;
  end;

  if (Setup.CarWashInterfaceType <> CWSRV_NONE) then
  begin
    StartMsg := Format('%2.2d',[CW_START_SERVER]);

    case Setup.CarWashInterfaceType of
      CWSRV_UNITEC, CWSRV_PDQ : DCOMCarWash.SendMsg('POS', ThisTerminalNo, StartMsg);
    end;

  end;

end;
//...cwa

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ConnectMOServer
  Author:    
  Date:      
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ConnectMOServer(reconnect: boolean);
begin
  UpdateZLog('TfmPOS.ConnectMOServer-tarang');
  if (ThisTerminalNo = MasterTerminalNo) and (mohost = 'localhost') and not CheckRunning('MOServer.exe') then
    StartProcess('\Latitude\MOServer.exe');
  if not assigned(MOTCPClient) then
  try
    MOTCPClient := TIdTCPClient.Create(Self);
    MOTCPClient.Port := 7114;
    MOTCPClient.Host := mohost;
    MOTCPClient.OnConnected := Self.MOConnected;
    MOTCPClient.OnDisconnected := Self.MODisconnected;
    MOTCPClient.Name := 'MOTCPClient';
    UpdateZLog('Attempting connection to Money Order Server (%s, %d)', [MOTCPClient.Host, MOTCPClient.Port]);
    MO := TTagTCPClient.Create(MOTCPClient, format('REG%d', [ThisTerminalNo]), AnsiReplaceStr(GetBuildInfoString(), 'Ver: ', ''), cipherlist);
    MO.OnRecv := Self.MOMsgRecv;
    MO.OnExceptLog := Self.MOLog;
    MO.OnLog := Self.MOLog;
    MO.Resume;
  except
    on E: Exception do
    begin
      ShowMessage ('Error connecting to Money Order Server Reason: ' + E.Message);
      FreeAndNil(MO);
      FreeAndNil(MOTCPClient);
    end;
  end;
end;

procedure TfmPOS.MOConnected(Sender : TObject);
begin
  UpdateZLog('Connected to Money Order Server');
  MOStatus.Status := tisOK;
end;

procedure TfmPOS.MODisconnected(Sender : TObject);
begin
  MOStatus.Status := tisNotOK;
  UpdateZLog('Disconnected from Money Order Server');
end;

procedure TfmPOS.MOLog(Sender : TObject; logmsg : string);
begin
  UpdateZLog('MOThread - %s', [logmsg]);
end;

procedure TfmPOS.MOMsgRecv(Sender : TObject; msg : string);
var
  OutData : pMsgData;
begin
    new(OutData);
    OutData^.Orig := 'MOSrvr';
    OutData^.Msg := Msg;
    OutData^.TerminalNo := ThisTerminalNo;
    MOList.Add(OutData);
    PostMessage(fmPOS.Handle,WM_MOMSG,0,0);
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.SendFuelMessage
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: PumpNo, Action : short; Amount : currency; SaleID, TransNo, DestPump : integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.SendFuelMessage(PumpNo, Action : short; Amount : currency; SaleID, TransNo, DestPump : integer);
var
  TryCount : integer;
  FuelSrvrMsg   : string;
  OutData : pOutFSData;
begin
  if NOT bClosingPOS then
  begin
    FuelSrvrMsg := BuildTag(FSTAG_PUMPNO, IntToStr(PumpNo) ) +
                     BuildTag(FSTAG_PUMPACTION, IntToStr(Action) );
    if Amount <> 0 then
        FuelSrvrMsg := FuelSrvrMsg + BuildTag(FSTAG_AMOUNT, CurrToStr(Amount) );

    if SaleID > 0 then
        FuelSrvrMsg := FuelSrvrMsg + BuildTag(FSTAG_SALEID, IntToStr(SaleID) );

    if TransNo > 0 then
        FuelSrvrMsg := FuelSrvrMsg + BuildTag(FSTAG_TRANSNO, IntToStr(TransNo) );

    if DestPump > 0 then
        FuelSrvrMsg := FuelSrvrMsg + BuildTag(FSTAG_DESTPUMP, IntToStr(DestPump) );



    for TryCount := 1 to 5 do
    begin
      try
        case nFuelInterfaceType of
          1,2 : SendRawFuelMessage(FuelSrvrMsg);
        end;
        break;
      except
        on E: Exception do
          if pos('input-synchronous',e.Message) > 0 then
          begin
            UpdateExceptLog('TfmPOS.SendFuelMessage failed, queueing message - %s - %s',[ E.ClassName, E.Message ]);
            New(OutData);
            OutData^.Orig := 'POSSrvr';
            OutData^.TerminalNo := ThisTerminalNo;
            OutData^.OutMsg := FuelSrvrMsg;
            OutFSList.Add(OutData);
            PostMessage(fmPOS.Handle,WM_OUTFSMSG,0,0);
            exit;
          end
          else
            ReconnectFuel('POS SendFuelMessage', e.message, FuelSrvrMsg, TryCount);
      end;
    end;
  end;
end;

function TfmPOS.FormatFinalizeAuth(const AuthID      : integer;
                                   const FinalAmount : currency;
                                   const TransNo     : integer;
                                   const salelist    : TNotList) : string;
var
  i : integer;
  sd : pSalesData;
  mr : longword;
begin
   UpdateZLog('inside TfmPOS.FormatFinalizeAuth function-tarang');
  //ShowMessage('inside TfmPOS.FormatFinalizeAuth function'); // madhu remove
  mr := $7fffffff;
  for i := 0 to pred( salelist.Count ) do
  begin
    sd := pSalesData( salelist[i] );
    if ( sd^.LineType = 'MED' ) and ( sd^.CCAuthId = authid ) then
    begin
      mr := sd^.mediarestrictioncode;
    end;
  end;
  FormatFinalizeAuth := BuildTag(TAG_MSGTYPE,    IntToStr(CC_FiNALiZE_AuTH)) +
           BuildTag(TAG_AuTHID,     IntToStr(AuthID)) +
           BuildTag(TAG_AUTHAMOUNT, Format('%10s',[( FormatFloat ( '###.00', FinalAmount))])) +
           BuildTag(TAG_TRANSNO,    Format('%6.6d',[TransNo])) +
           BuildTag(TAG_SALESDATA,  fmNBSCCForm.FormatSalesData(SaleList, AuthID, mr));
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.SendCreditMessage
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CreditMsg : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.SendCreditMessage(CreditMsg : string);
var
  TryCount : integer;
begin
  UpdateZLog('inside TfmPOS.SendCreditMessage function-tarang');
//  ShowMessage('inside TfmPOS.SendCreditMessage function'); // madhu remove
  if NOT bClosingPOS then
  begin
    for TryCount := 1 to 5 do
    begin
      try
        if (CreditHostReal(nCreditAuthType)) then
        begin
           UpdateZLog('Before:Credit.SendMsg(CreditMsg);-tarang');
          Credit.SendMsg(CreditMsg);
           UpdateZLog('after: Credit.SendMsg(CreditMsg);-tarang');
        //  ShowMessage('inside TfmPOS.SendCreditMessage function and Credit.SendMsg(CreditMsg);'); // madhu remove
          UpdateZLog('SendCreditMessage - %s', [DeformatCreditMsg(CreditMsg)]);
        end;
        break;
      except
        on E: Exception do
          ReconnectCredit('POS SendCreditMessage', e.message, CreditMsg, TryCount);
      end;
    end;
  end;

end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.SendFuelMessage
  Author:
  Date:
  Arguments: FuelMsg : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.SendRawFuelMessage(FuelMsg : string);
var
  TryCount : integer;
begin
  if NOT bClosingPOS then
  begin
    for TryCount := 1 to 5 do
    begin
      try
        if bFuelMsgLogging then
          UpdateZLog('SendRawFuelMessage: %s', [DeformatFuelMsg(FuelMsg)]);
        Fuel.SendMsg(FuelMsg);
        break;
      except
        on E: Exception do
          ReconnectFuel('POS SendRawFuelMessage', e.message, FuelMsg, TryCount);
      end;
    end;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.SendMOSMessage
  Author:
  Date:      2008-12-01
  Arguments: Msg : string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.SendMOSMessage(Msg : string);
begin
  if NOT bClosingPOS then
  begin
    UpdateZLog('Sending "' + Msg + '" to MOServer');
    MO.SendMsg(Msg);
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.SendCarWashMessage
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CarWashMsg : string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.SendCarWashMessage(CarWashMsg : string);
var
  TryCount : integer;
begin
  if NOT bClosingPOS then
  begin
    for TryCount := 1 to 5 do
    begin
      try
        case Setup.CarWashInterfaceType of
          CWSRV_UNITEC, CWSRV_PDQ : DCOMCarWash.SendMsg('POS', ThisTerminalNo, CarWashMsg);
        end;
        break;
      except
        on E: Exception do
          ReconnectCarWash('POS SendCarWashMessage', e.message, CarWashMsg, TryCount);
      end;
    end;
  end;
end;
//...cwa


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ReConnectFuel
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CalledFrom, EMess, FuelMsg : string ;TryCOunt : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ReConnectFuel(CalledFrom, EMess, FuelMsg : string ;TryCOunt : integer);
begin
  UpdateExceptLog(Calledfrom + ' ' + Fuelmsg + ' ' + emess + ' Try ' + Inttostr(Trycount) );
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ReConnectCredit
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CalledFrom, EMess, CreditMsg : string ;TryCOunt : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ReConnectCredit(CalledFrom, EMess, CreditMsg : string ;TryCOunt : integer);
begin
  UpdateExceptLog(CalledFrom + ' ' + CreditMsg + ' ' + emess + ' Try ' + IntToStr(TryCount) );
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ReConnectCarWash
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CalledFrom, EMess, CarWashMsg : string ;TryCOunt : integer
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ReConnectCarWash(CalledFrom, EMess, CarWashMsg : string ;TryCOunt : integer);
begin
  UpdateExceptLog(CalledFrom + ' ' + CarWashMsg + ' ' + emess + ' Try ' + IntToStr(TryCount) );
  case Setup.CarWashInterfaceType of
    CWSRV_UNITEC, CWSRV_PDQ :
      begin
        try
          if DCOMCarwash = nil then
          begin
            try
              if (CarwashEvents <> NIL) then
              begin
                CarwashEvents.Disconnect;
                CarwashEvents.Free;
                CarwashEvents := nil;
              end;
            except
            end;
            if MasterTerminalNo = ThisTerminalNo then
              //DCOMCarwash := CoTCarwash.Create
              DCOMCarwash := CoCarwashOLE.Create
            else
              DCOMCarwash := CoCarwashOLE.CreateRemote(MasterTerminalUNCName);//CoTCarwash.CreateRemote(MasterTerminalUNCName);
            if (CarwashEvents <> NIL) then CarwashEvents.Free;
//            CarwashEvents := TCarWashSrvrICarWashEvents.Create (Self);
//            CarwashEvents.GotMsgEvent := CarwashEventsGotMsgEvent;
            CarwashEvents := TCarwashICarwashOLEEvents.Create(Self);
            CarwashEvents.GotMsg := CarwashEventsGotMsg;
            CarwashEvents.Connect (DCOMCarwash);
          end
          else
          try
            try
              if (CarwashEvents <> NIL) then
              begin
                CarwashEvents.Disconnect;
                CarwashEvents.Free;
                CarwashEvents := nil;
              end;
            except
            end;
            DCOMCarwash := nil;
            if MasterTerminalNo = ThisTerminalNo then
              //DCOMCarwash := CoTCarwash.Create
              DCOMCarwash := CoCarwashOLE.Create
            else
              DCOMCarwash := CoCarwashOLE.CreateRemote(MasterTerminalUNCName);//CoTCarwash.CreateRemote(MasterTerminalUNCName);
            if (CarwashEvents <> NIL) then CarwashEvents.Free;
//            CarwashEvents := TCarwashSrvrICarwashEvents.Create (Self);
//            CarwashEvents.GotMsgEvent := CarwashEventsGotMsgEvent;
            CarwashEvents := TCarwashICarwashOLEEvents.Create(Self);
            CarwashEvents.GotMsg := CarwashEventsGotMsg;
            CarwashEvents.Connect (DCOMCarwash);
          except
          end;
          UpdateExceptLog('ReConnected' );
        except
          on E: Exception do
            begin
              UpdateExceptLog('Carwash ReConnect Failed Reason: ' + E.Message );
              DCOMCarWash := nil;
              CarwashEvents := nil;
            end;
        end;
      end;
  end;

end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.GetCarwashAccessCode
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: qSalesData : pSalesData
  Result:    string
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.GetCarwashAccessCode(qSalesData : pSalesData) : string;
{Extract carwash access code from a sales item.  Return '' if sales item is not a carwash.}
begin
  if ((qSalesData^.LineType = 'PLU') and
      ( qSalesData^.ActivationState = asActivationDoesNotApply ) and  // Activation products use the same field as used to store CW codes
      ( not qSalesData^.LineVoided) and (qSalesData^.SaleType <> 'Void')) then
    begin
      GetCarWashAccessCode := Trim(qSalesData^.CCCardName);  // (CardName field only contains card name with Line Type of 'MED'.)
    end
  else
    begin
      GetCarWashAccessCode := '';
    end;
end;
//...cwa


{-----------------------------------------------------------------------------
  Name:      TfmPOS.GetXMDEarned
  Author:    Gary Whetton
  Date:      08-Mar-2004
  Arguments: qSalesData : pSalesData
  Result:    string
  Purpose:
-----------------------------------------------------------------------------}
//XMD
function TfmPOS.GetXMDEarned(qSalesData : pSalesData) : string;
var
  Ret : string;
{Extract XMD code from a sales item.  Return '' if sales item is not a XMD.}
begin
  if ((qSalesData^.LineType = 'XMD') and ( not qSalesData^.LineVoided) and (qSalesData^.SaleType = 'Sale')) then
  begin
    Ret := Trim(qSalesData^.CCCardName);
  end
  else
    Ret := '';
  GetXMDEarned := Ret;
end;
//XMD


{-----------------------------------------------------------------------------
  Name:      TfmPOS.GetCarwashExpDate
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: qSalesData : pSalesData
  Result:    string
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.GetCarwashExpDate(qSalesData : pSalesData) : string;
{Extract carwash expiration date from a sales item.  Return '' if sales item is not a carwash.}
begin
  if ((qSalesData^.LineType = 'PLU') and ( not qSalesData^.LineVoided) and (qSalesData^.SaleType <> 'Void')) then
    begin
      GetCarWashExpDate := Trim(qSalesData^.CCExpDate);  // (ExpDate field only contains card exp. date with Line Type of 'MED'.)
    end
  else
    begin
      GetCarWashExpDate := '';
    end;
end;
//...cwf


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ReConnectPrinter
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: CalledFrom, EMess : string ;TryCOunt : integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ReConnectPrinter(CalledFrom, EMess : string ;TryCOunt : integer);
begin

  UpdateExceptLog(CalledFrom + ' ' + emess + ' Try ' + IntToStr(TryCount) );
  fmPOSMsg.ShowMsg('Restarting Printer...', '');
  try
    try
      DCOMPrinter.StopServer;
    except;
      fmPOSMsg.Close;
    end;
    try
      if (ReceiptEvents <> NIL) then
      begin
        ReceiptEvents.Disconnect;
        ReceiptEvents.Free;
        ReceiptEvents := nil;
      end;
    except
    end;
    DCOMPrinter := nil;
    DCOMPrinter := CoTReceipt.Create;
    if (ReceiptEvents <> NIL) then ReceiptEvents.Free;
    ReceiptEvents := TReceiptSrvrITReceiptEvents.Create (Self);
    ReceiptEvents.GotPrinterError := ReceiptEventsGotPrinterError;
    ReceiptEvents.Connect (DCOMPrinter);
    //DCOMPrinter.AddLine(PRT_PAUSEPRINT, '' );
    DCOMPrinter.InitPrinter(PtrDeviceNo, PtrDriver, PtrPort, PtrBaud, PtrData, PtrStop, PtrParity, PtrOPOSName, ExtractFileDir(Application.ExeName) + '\' + Setup.PrtLogoName);
    //DCOMPrinter.InitDrawer(DwrDeviceType, DwrDriver, DwrPort, DwrBaud, DwrData, DwrStop, DwrParity, DwrOPOSName);
    //20070228a...
    if (DwrDeviceType > 0) then
      DCOMPrinter.InitDrawer(DwrDeviceType, DwrDriver, DwrPort, DwrBaud, DwrData, DwrStop, DwrParity, DwrOPOSName);
    //...20070228
    //DCOMPrinter.AddLine(PRT_STARTPRINT, '' );
    fmPOSMsg.Close;
  except
    on E: Exception do
      begin
        UpdateExceptLog('ReceiptServer ReConnect Failed Reason: ' + E.Message );
        fmPOSMsg.Close;
      end;
  end;
end;

procedure ExtractVCI(const msg : widestring; const pVCI : pValidCardInfo);
var
   Track2Equiv : widestring;
begin
  ZeroMemory(pVCI, sizeof(TValidCardInfo));
  pVCI.UPC               := 0;
  pVCI.Track1Data        := GetTagData(TAG_TRACK1DATA, Msg);
  pVCI.Track2Data        := GetTagData(TAG_TRACK2DATA, Msg);
  pVCI.CardError         := GetTagData(TAG_ERRORSTRING, Msg);
  pVCI.CardType          := GetTagData(TAG_CARDTYPE, Msg);
  pVCI.CardTypeName      := GetTagData(TAG_VC_CardTypeName, Msg);
  pVCI.bActivationType   := TextToBool(GetTagData(TAG_VC_ActivationType, Msg));
  pVCI.bGetPIN           := TextToBool(GetTagData(TAG_VC_GetPIN, Msg));
  pVCI.bGetDriverID      := TextToBool(GetTagData(TAG_VC_GetDriverId, Msg));
  pVCI.bGetID            := TextToBool(GetTagData(TAG_VC_GetID, Msg));
  pVCI.bGetOdometer      := TextToBool(GetTagData(TAG_VC_GetOdometer, Msg));
  pVCI.bGetRefNo         := TextToBool(GetTagData(TAG_VC_GetRefNo, Msg));
  pVCI.bGetVehicleNo     := TextToBool(GetTagData(TAG_VC_GetVehicleNo, Msg));
  pVCI.bGetZIPCode       := TextToBool(GetTagData(TAG_VC_GetZIP, Msg));
  pVCI.bAskDebit         := TextToBool(GetTagData(TAG_VC_AskDebit, Msg));
  pVCI.bDebitBINMngt     := TextToBool(GetTagData(TAG_VC_DebitBIN, Msg));
  pVCI.bValid            := TextToBool(GetTagData(TAG_VC_VALID, Msg));
  pVCI.EncryptedTrackData:= GetTagData(TAG_ENCRYPTEDTRACKDATA, Msg);
  //try Track2Equiv := GetTagData(TAG_EMVT2EQUIV, Msg); pVCI.EncryptedTrackData:= Copy(Track2Equiv,4,Length(Track2Equiv) - 3); except Track2Equiv := ''; end;
  pVCI.mediarestrictioncode := StrToInt64Def(GetTagData(TAG_RESTRICTION_CODE, Msg), MRC_CREDITDEFAULT);
  if (pVCI.bValid) then
  begin
    pVCI.iFaceValueCents   := StrToIntDef(GetTagData(TAG_VC_FaceValueCents, Msg), 0);
    pVCI.CardNo        := GetTagData(TAG_CARDNO, Msg);
    pVCI.ExpDate       := GetTagData(TAG_EXPDATE, Msg);
    pVCI.ServiceCode   := GetTagData(TAG_SERVICECODE, Msg);
    pVCI.CardName      := GetTagData(TAG_CARDNAME, Msg);
    pVCI.VehicleNo     := GetTagData(TAG_VEHICLENO, Msg);
    pVCI.UPC           := -StrToCurrDef(GetTagData(TAG_VC_SKU, Msg), 0);
    pVCI.EntryMethod   := GetTagData(TAG_ENTRYMETHOD, Msg);
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.CCSocketReceiveMessage
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Orig: string; TerminalNo : Integer; Msg: string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
//procedure TfmPOS.CCSocketReceiveMessage(Orig: string; TerminalNo : Integer; Msg: string);
procedure TfmPOS.CCSocketReceiveMessage(var XMsg : TMessage);
var
 Action : short;
 TerminalNo : integer;
 Msg, Orig : string;
 InData : pCCData;
 tmpString : string;  //20070227c
 CCL : TList;
 pVCI : pValidCardInfo;
 seqno : integer;
 sli : integer;
 alreadyused : boolean;
 sd : pSalesData;
 reqid : string;
 o : TObject;
begin
  InData := nil;
  try
    CCL := CCList.LockList();
    CCL.Pack;
    if CCL.Count > 0 then
    begin
      InData := CCL.First();
      CCL.Delete(0);
    end;
  finally
    CCList.UnlockList();
  end;
  if indata <> nil then
  begin
    Msg := Indata^.Msg;
    Orig := InData^.Orig;
    TerminalNo := InData^.TerminalNo;
    dispose(InData);
    UpdateZLog('Credit Message Received: %s', [DeformatCreditMsg(Msg)]);
    reqid := GetTagData('REQID', Msg);
    if reqid <> '' then
    begin
      sli := CreditDefs.IndexOf(reqid);
      if sli >= 0 then
      begin
        o := CreditDefs.Objects[sli];
        TMsgRecCallMe(o).call(msg);
        o.Destroy;
        CreditDefs.Delete(sli);
      end;
    end
    else if TerminalNo = ThisTerminalNo then
    begin
      try
        Action :=  StrToInt(GetTagData(TAG_MSGTYPE, Msg))
      except
        Action := 0;
      end;
      if Action = CC_CLOSEBATCH then
      begin
        try
          tmpString := GetTagData(TAG_CLOSEBATCHID, Msg);
          if (tmpString <> '') then
            nCreditBatchID := StrToInt(tmpString)
          else
            nCreditBatchID := 0;
        except
          nCreditBatchID := 0;
        end;

        try
          tmpString := GetTagData(TAG_CLOSEBATCHPDL, Msg);
          if (tmpString <> '') then
            nCreditBatchPDL := StrToInt(tmpString)
          else
            nCreditBatchPDL := 0;
        except
          nCreditBatchPDL := 0;
        end;
        fCreditTotals := False;
      end
      else if Action = CC_VALIDCARD_RESP then
      begin
        alreadyused := False;
        new(pVCI);
        ExtractVCI(msg, pVCI);
        seqno := StrToInt(GetTagData(TAG_VC_SEQNO, Msg));
        UpdateZLog('Shesh for Validcard Msg1 ');
        case seqno of
          VC_RET_PPCARDINFORECEIVED : pVCI.cardsource := csPinPad;
          VC_RET_NBSCC_PROCESSKEY   : pVCI.cardsource := csManual;
          VC_MSRSWIPE               : pVCI.cardsource := csMSR;
          VC_RET_GIFT_PROCESSKEY    : pVCI.cardsource := csManual;
        end;
        if not pVCI.bValid then
        begin
          if pVCI.cardsource in [csMSR, csManual] then
            POSError('Card not valid at this location', pVCI.CardError)
          else if pVCI.cardsource = csPinPad then
          begin
            UpdateZLog('Shesh for Validcard Msg2 ');
            AbortPinPadOperation;
            POSError('Card swiped at PINPad not valid', pVCI.CardError);
          end;
          if seqno = VC_RET_NBSCC_PROCESSKEY then
            fmNBSCCForm.Close
          else if seqno = VC_RET_GIFT_PROCESSKEY then
            fmGiftForm.Close;
          UpdateZLog('Shesh for Validcard Msg3 ');
        end
        else
        begin
          if (CurSaleList.Count > 0) then
            for sli := 0 to Pred(CurSaleList.Count) do
              if (not alreadyused) then
              begin
                sd := pSalesData(CurSaleList.Items[sli]);
                alreadyused := (sd.LineType = 'MED') and (sd.CCCardNo = pVCI^.CardNo);
              end;
          if not alreadyused then
          begin
            UpdateZLog('Passing VCI to %d', [seqno]);
            case seqno of
              VC_RET_PPCARDINFORECEIVED : if ((Self.SaleState = ssSale) or
                                              ((Self.SaleState = ssTender) and (curSale.nAmountDue <> 0.0))) then
                                          begin
                                            PPVCIReceived(pVCI);
                                            fmNBSCCForm.VCIReceived(pVCI);
                                          end;
              VC_RET_NBSCC_PROCESSKEY : fmNBSCCForm.VCIReceived(pVCI);
              VC_MSRSWIPE : MSRSwipeVCI(pVCI);
              VC_RET_GIFT_PROCESSKEY : fmGiftForm.VCIReceived(pVCI);
            end;
          end
          else
          begin
            if seqno <> VC_RET_GIFT_PROCESSKEY then
              AbortPinPadOperation;
            POSError('Card already used on transaction');
          end;
        end;
        ZeroMemory(pVCI, sizeof(TValidCardInfo));
        dispose(pVCI);
      end
      else
      begin
        if (CreditHostReal(nCreditAuthType)) then
        begin
          UpdateZLog('Shesh for MSR Auth ');
          if fmGiftForm.Visible then
          begin
            fmGiftForm.ProcessCreditMsg(msg);
          end
          else if fmNBSCCForm.Visible then
          begin
            fmNBSCCForm.ProcessCreditMsg(Msg);
          end
          else if (Action in [CC_AUTHMSG_ACT, CC_AUTHRESP_ACT, CC_BALANCERESP]) then
          begin // Re-route messages from credit server related to card activations.
            New(StatusMsg);
            StatusMsg.Text := Msg;
            PostMessage(fmPOS.Handle, WM_ACTIVATION, 0, LongInt(StatusMsg));
          end;
        end;
      end;
    end;
  end;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.MOSocketReceiveMessage
  Author:    Mike Mattice
  Date:      2008-08-12
  Arguments: Orig: string; TerminalNo : Integer; Msg: string
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.MOSocketReceiveMessage(var XMsg : TMessage);
var
 TerminalNo : integer;
 Msg, Orig : string;
 InData : pMsgData;
 MOL : TList;
begin
  InData := nil;
  try
    MOL := MOList.LockList();
    if MOL.Count > 0 then
    begin
      InData := MOL.First();
      MOL.Delete(0);
    end;
  finally
    MOList.UnlockList();
  end;
  if InData <> nil then
  begin
    TerminalNo := InData^.TerminalNo;
    Orig := InData^.Orig;
    Msg := Indata^.Msg;
    Dispose(InData);
    
    if TerminalNo = ThisTerminalNo then
    begin
      New(StatusMsg);
      StatusMsg.Text := Msg;
      PostMessage(fmMO.Handle, WM_MOMSG, 0, LongInt(StatusMsg));
    end;
  end;
end;

procedure TfmPOS.CCSendMsg(const msg : string; const respdest : TMsgRecEvent);
var
  reqid : Integer;
begin
  UpdateZLog('inside TfmPOS.CCSendMsg function-tarang');
  //ShowMessage('inside TfmPOS.CCSendMsg function'); // madhu remove
  reqid := RandomRange(1, MaxInt);
  CreditDefs.AddObject(IntToStr(reqid), TMsgRecCallMe.Create(respdest));
  UpdateZLog('SendCreditMessage TAGS = ' + BuildTag('REQID', IntToStr(reqid)) + msg);
  SendCreditMessage(BuildTag('REQID', IntToStr(reqid)) + msg);
   UpdateZLog('END: TfmPOS.CCSendMsg function-tarang');
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CWSocketReceiveMessage
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Orig: string; TerminalNo : Integer; Msg: string
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.CWSocketReceiveMessage(Orig: string; TerminalNo : Integer; Msg: string);
begin
  //cwj...
  if TerminalNo = ThisTerminalNo then
  begin
    try
      if (StrToInt(GetTagData(TAG_MSGTYPE, Msg)) = CW_EOD_AUDIT_RESPONSE) then
        fCarwashTotals := False;          // signal to EOD process that carwash server is done with EOD.
    except
    end;
  end;
  //...cwj
  if (fmCWAccessForm.Visible) then
  begin
    New(StatusMsg);
    StatusMsg.Text := Msg;
    PostMessage(fmCWAccessForm.Handle, WM_CARWASH_MSG, 0, LongInt(StatusMsg));
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisplayReceiptErrorMessage
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var Msg: TWMReceiptErrorMsg
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.DisplayReceiptErrorMessage(var Msg: TWMReceiptErrorMsg);
var
  s, supp : string;
begin
  s := (Msg.ReceiptErrorMsg.Text);
  Dispose(Msg.ReceiptErrorMsg);
  supp := '';
  if assigned (Msg.Detail) then
  begin
    supp := Msg.Detail.Text;
    Dispose(Msg.Detail);
  end;
  POSError(s, supp);
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.Show1Click
  Author:
  Date:      13-Apr-2004
  Arguments:
  Sender: TObject
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.SysMgr1Click(Sender: TObject);
var
  dirname : string;
  pdirname : array[0..200] of char;
begin
  dirname := ExtractFileDir(Application.ExeName);
  StrPCopy(pdirname, dirname);
  ShellExecute(Handle,'open','SysMgr.exe','', pdirname ,sw_show);
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.Exit1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.Exit1Click(Sender: TObject);
begin
  bPOSForceClose := True;
  if bReceiptActive <> 0 then
  try
    DCOMPrinter.StopServer;
  except
  end;
  Close;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.LoggingOn1Click
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.LoggingOn1Click(Sender: TObject);
begin
  bLogging := not bLogging;
  try
    POSRegEntry := TRegIniFile.Create('Latitude');
    POSRegEntry.WriteBool('LatitudeConfig', 'Logging', bLogging);
    POSRegEntry.Free;
  except
  end;
  UpdateLoggingDisplay;
end;

procedure TfmPOS.UpdateLoggingDisplay();
begin
  if bLogging then
    LoggingOn1.Caption := 'Logging is On'
  else
    LoggingOn1.Caption := 'Logging is Off';
  if SyncLogs then
    SyncLogging1.Caption := 'Logs are Synced'
  else
    SyncLogging1.Caption := 'Logs are Buffered';
end;

{$IFDEF FF_PROMO_20080128}
function TfmPOS.VerifyFuelFirstCard(const CardNumberUsed : string) : boolean;
{
Verify that the card number swiped (or manually entered) matches the card used for
the transaction.
}
var
  SaveTitle : string;
//  j : integer;
  NeedFuelFirstCardSwipe : boolean;
  ReturnValue : boolean;
  SaveNBSCCFormColor : TColor;
begin
  ReturnValue := False;  // Initial assumption.
  SaveTitle := fmNBSCCForm.Caption;
  fmNBSCCForm.Caption := 'Verfiy Fuel First Card';
  qClient^.GiftCardUsage := GC_VERIFY_FUEL_FIRST;
  qClient^.CreditTransNo := nCurTransNo;
//  for j := 1 to StrToInt(CurrToStr(nQty)) do
//  begin
    NeedFuelFirstCardSwipe := True;
    while (NeedFuelFirstCardSwipe) do
    begin
      FuelFirstCardNoUsed := CardNumberUsed;
      fmNBSCCForm.SetCCClientData(nCurTransNo, GC_VERIFY_FUEL_FIRST);
      fmNBSCCForm.EntryBuff := '';
      fmNBSCCForm.MSRData := '';
      fmNBSCCForm.GiftCardCashoutOption   := CO_DEFAULT;
      fmNBSCCForm.Authorized              := 0;
      fmNBSCCForm.ChargeAmount            := nAmount;
      fmNBSCCForm.GiftCardRestrictionCode := RC_UNKNOWN;
      fmNBSCCForm.GiftCardStatus          := CS_UNKNOWN;
      fmNBSCCForm.GiftCardBalance         := UNKNOWN_BALANCE;
      fmNBSCCForm.AmountDue               := 0.0;
      fmNBSCCForm.TaxAmount               := 0.0;
      fmNBSCCForm.CreditAuthToken         := CA_IDLE;
      SaveNBSCCFormColor                  := fmNBSCCForm.Color;
      fmNBSCCForm.Color                   := clPurple;
      fmNBSCCForm.InitialScreen();
      fmNBSCCForm.ShowModal;    // fuel first verify

      fmNBSCCForm.Color := SaveNBSCCFormColor;
      ReturnValue := (Trim(fmNBSCCForm.CardNo) = CardNumberUsed);
      if ReturnValue then ReturnValue := False;  //(todo) remmove
      if bMSRActive = 2 then
      begin
        if CheckNCRMSR(MSROPOSName) then
        begin
          OPOSMSR.DeviceEnabled := True;{ DONE : chage to generic in case not OPOS pin pad }
          OPOSMSR.DataEventEnabled := True;
        end
        else if (POSIOPOSMSR <> nil) then  //20060605 - added check for null pointer.
        begin
          POSIOPOSMSR.DeviceEnabled := True;{ DONE : chage to generic in case not OPOS pin pad }
          POSIOPOSMSR.DataEventEnabled := True;
        end;
      end;
      fmNBSCCForm.Caption := SaveTitle;
      if (False) then
      begin
        if bPINPadActive > 0 then
        try
          {$IFDEF DEV_PIN_PAD}
          DCOMPinPad.CancelPrompt(PINPAD_PROMPT_ANY, NOPINPADPROMPT_IDLE);
          {$ELSE}
          DCOMPinPad.SetPrompt(NOPINPADPROMPT_IDLE);
          {$ENDIF}
        except
          UpdateExceptLog('Reconnecting to Pin Pad');
          ReconnectPinPad('VerifyFuelFirstCard1');
        end;
        break;  // User hit "CLR" instead of swiping card.
      end;
      NeedFuelFirstCardSwipe := False;  // Continue with next card (if any)
    end;  // while (NeedFuelFirstCardSwipe)
    if (False) then
    begin
      if bPINPadActive > 0 then
      try
        {$IFDEF DEV_PIN_PAD}
        DCOMPinPad.CancelPrompt(PINPAD_PROMPT_ANY, NOPINPADPROMPT_IDLE);
        {$ELSE}
        DCOMPinPad.SetPrompt(NOPINPADPROMPT_IDLE);
        {$ENDIF}
      except
        UpdateExceptLog('Reconnecting to Pin Pad');
        ReconnectPinPad('VerifyFuelFirstCard2');;
      end;
//      break;  // User hit "CLR" instead of swiping card.
    end;
//  end;  // for j := 1 to StrToInt(CurrToStr(nQty))
  fmNBSCCForm.EntryBuff := '';
  fmNBSCCForm.MSRData := '';
  //53i...
  fmNBSCCForm.SetCCClientData(nCurTransNo, GC_PURCHASE);
  //...53i
  qClient^.GiftCardUsage := GC_NONE;
  qClient^.CreditTransNo := nCurTransNo;  // Just to be consistent.  Doesn't really apply here.
  VerifyFuelFirstCard := ReturnValue;
end;  // function VerifyFuelFirstCard
{$ENDIF}  // FF_PROMO_20080128

{-----------------------------------------------------------------------------
  Name:      TfmPOS.GiftCardBalanceInquiry
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.GiftCardBalanceInquiry();
begin
  fmGiftForm.Show;
  while fmGiftForm.Visible = True do
  begin
    Application.ProcessMessages;
    sleep(20);
  end;
end;

procedure TfmPos.BuildCardTypeList();
var
  rec : pDBCCCardTypesRec;
begin
  if not assigned(FCCCardTypesList) then
    FCCCardTypesList := TStringList.Create();
  with POSDataMod.IBRptSQL01Main do
  begin
    Transaction.StartTransaction;
    SQL.SetText('Select * from CCCardTypes order by CardType');
    ExecQuery;
    while not Eof do
    begin
      new(rec);
      GetCCCardType(POSDataMod.IBRptSQL01Main, rec);
      FCCCardTypesList.AddObject(rec.cardtype, TObject(rec));
      Next;
    end;
    Close();
    Transaction.Commit;
  end;
end;

function TfmPos.GetCardTypeNameByCardType(const cardtype : string) : string;
var
  i : integer;
begin
  i := FCCCardTypesList.IndexOf(cardtype);
  result := pDBCCCardTypesRec(FCCCardTypesList.Objects[i]).fullname;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPos.BuildRestrictedDeptList
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPos.BuildRestrictedDeptList();
var
  j : integer;
  q : pRestrictedDept;
  GiftCardRC : integer;
begin
  // Clear out memory copy.
  if RestrictedDeptList.Count > 0 then
  for j := 0 to RestrictedDeptList.Count - 1 do
  begin
    try
      q := RestrictedDeptList.Items[j];
      Dispose(q);
    except
    end;
    RestrictedDeptList.Items[j] := nil;
  end;
  RestrictedDeptList.Pack();
  RestrictedDeptList.Capacity := RestrictedDeptList.Count;
  // Load new values from DB to memory (only with non-zero restriction codes).
  if not POSDataMod.IBTempTrans1.InTransaction then
    POSDataMod.IBTempTrans1.StartTransaction;
  with POSDataMod.IBTempQry1 do
  begin
    Close;SQL.Clear;
    SQL.Add('Select * from Dept where RestrictionCode > 0');
    Open();
    while not EOF do
    begin
      GiftCardRC := ((FieldByName('RestrictionCode').AsInteger) div
                       MAX_NUM_RESTRICTION_CODES) mod MAX_NUM_RESTRICTION_CODES;
      if (GiftCardRC > 0) then
      begin
        New(q);
        q^.DeptNo          := FieldByName('DeptNo').AsInteger;
        q^.RestrictionCode := GiftCardRC;
        RestrictedDeptList.Capacity := RestrictedDeptList.Count;
        RestrictedDeptList.Add(q);
      end;
      Next;
    end;
    close();
  end;
  if POSDataMod.IBTempTrans1.InTransaction then
    POSDataMod.IBTempTrans1.Commit;
end;  // procedure BuildRestrictedDeptList


{-----------------------------------------------------------------------------
  Name:      TfmPos.ProcessKeyGFT
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPos.ProcessKeyGFT;
var
  qtyString : string;
  gamount : string;
  camt : currency;
  iQty : integer;
  j : integer;
begin
  if lbReturn.Visible = True then
  begin
    POSError('Gift Card Return Not Allowed');
    lbReturn.Visible := false;
    exit;
  end;
  if sEntry = '' then
  begin
    if CurSaleList.Count = 0 then
    begin
      GiftCardBalanceInquiry();
      exit;
    end
    else
      POSError('Gift Card Balance Not Available During Sale Transaction');
  end
  else
  begin
    nAmount := strtocurr(sEntry)/100;
    if (Frac(nAmount/GiftCardFaceValueInc) <> 0) then
      POSError('Gift card face value must be increment of $' + CurrToStr(GiftCardFaceValueInc))
    else
    begin
      if nQty = 0 then
        nQty := 1;
      gAmount := sEntry;
      iQty := Round(nQty);
      for j := 1 to iQty do
      begin
        sEntry := gAmount;
        camt := strtocurr(sEntry)/100;
        ActivationProductData.bNextSwipeForProduct := True;
        ActivationProductData.ActivationUPC := '';
        ActivationProductData.ActivationAmount := nAmount;
        ActivationProductData.ActivationCardType := CT_GIFT;
        if (iQty > 1) then
          QtyString := Format('%d of %d', [j, iQty])
        else
          QtyString := '';
        UpdateZLog('Issuing Gift Card swipe prompt %s', [QtyString]);
        IssueCardActivationPrompt(Format('Swipe Gift Card %sTo Be Activated For %s', [QtyString, FormatFloat('#,###.00 ;#,###.00-',camt)]));
        while fmPOSErrorMsg.Visible and (fmPOSErrorMsg.Tag = POS_ERROR_MSG_TAG_CARD_ACTIVATION) do
        begin
          Application.ProcessMessages;
          sleep(20);
        end;
      end;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPos.ProcessKeyCWH
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: 
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPos.ProcessKeyCWH();
var
  iPLUNo : int64;
  sAccessCode : string;
  //cwf...
  sCWExpDate : string;
  //...cwf
  bAccessApproved : boolean;
begin
  sCarwashAccessCode := '';
  //cwf...
  sCarwashExpDate := '';
  //...cwf
  iPLUNo := 0;
  //cwf..
//  sAccessCode := RequestCarwashAccessCode(iPLUNo);
  sAccessCode := RequestCarwashAccessCode(iPLUNo, sCWExpDate);
  //...cwf
  bAccessApproved := (sAccessCode <> '');
  // If a carwash access code was granted, then continue processing item as a PLU.
  if (bAccessApproved) then
    begin
      sCarwashAccessCode := sAccessCode;
      //cwf...
      sCarwashExpDate := sCWExpDate;
      //...cwf
      ProcessKeyPLU(IntToStr(iPLUNo),'');
      sCarwashAccessCode := '';
      //cwf...
      sCarwashExpDate := '';
      //...cwf
    end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyCWR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyCWR;
begin
  try
    if CarwashEvents <> nil then
    begin
      CarwashEvents.Disconnect;
      CarwashEvents.Free;
      CarwashEvents := nil;
    end;
  except
  end;
  if ThisTerminalUNCName = MasterTerminalUNCName then
  try
    //DCOMCarwash.ForceCloseCarWash;
    DCOMCarwash.CloseCarWash;
    DCOMCarwash := nil;
  except
  end;
  ReconnectCarwash('Reset','No Error','',1);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.RequestCarwashAccessCode
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: var CarwashPLUNo : int64; var sCWExpDate : string
  Result:    string
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.RequestCarwashAccessCode(var CarwashPLUNo : int64; var sCWExpDate : string) : string;
//...cwf
{Request a carwash access code from the carwash server.  If CarwashPLUNo is zero, then carwash screen will prompt
for the carwash product and will this function will return with the PLU selected.}
var
  bAccessApproved : boolean;
begin
  //cwi...
  // Carwashes cannot be purchased in quanity.
  if (nQty <> 1) then
  begin
    POSError('Carwash quanity must be 1');
    RequestCarwashAccessCode := '';
    exit;
  end;
  //...cwi
  if (SaleState = ssNoSale) then
      AssignTransNo();

  fmCWAccessForm.SetCWClientData(curSale.nTransNo, GC_NONE);
  qCWClient^.CarwashTransNo := curSale.nTransNo;  // Used to match responses from credit server.
  ReComputeSaleTotal(True);
  fmCWAccessForm.Authorized := CW_AUTHORIZED_NOT_SET;
  if (CarwashPLUNo = 0) then
    begin
      fmCWAccessForm.CarwashInterfaceState := CI_IDLE;
    end
  else
    begin
      fmCWAccessForm.CarwashInterfaceState := CI_BUILD_CODE_REQUEST;
    end;
  fmCWAccessForm.CWPLUNo := CarwashPLUNo;
  fmCWAccessForm.CWAccessCode := '';
  sCarwashAccessCode := '';
  //cwf...
  sCarwashExpDate := '';
  //...cwf
  fmCWAccessForm.Initialize := True;
  fmCWAccessForm.Show;

  //PostMessage(fmCWAccessForm.Handle, WM_INITSCREEN,0 ,0);

  while (fmCWAccessForm.Visible) do
  begin
    Application.ProcessMessages;
    sleep(20);
  end;
  bAccessApproved := (fmCWAccessForm.Authorized = CW_AUTHORIZED_YES);
  CarwashPLUNo := fmCWAccessForm.CWPLUNo;

  //cwf...
  if (fmCWAccessForm.CWDaysToExpire >= 0) then
      sCWExpDate := FormatDateTime('mm/dd/yy', Date() + fmCWAccessForm.CWDaysToExpire)
  else
      sCWExpDate := '';
  //...cwf

  fmCWAccessForm.SetCWClientData(curSale.nTransNo, GC_NONE);

  if (bAccessApproved) then RequestCarwashAccessCode := fmCWAccessForm.CWAccessCode
                       else RequestCarwashAccessCode := '';
end;
//...cwe


{-----------------------------------------------------------------------------
  Name:      TfmPOS.OPOSMSRErrorEvent
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; ResultCode, ResultCodeExtended, ErrorLocus: Integer; var pErrorResponse: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.OPOSMSRErrorEvent(Sender: TObject; ResultCode,
  ResultCodeExtended, ErrorLocus: Integer; var pErrorResponse: Integer);
begin
  POSError('Bad Swipe - Try Again');
  if CheckNCRMSR(MSROPOSName) then
  try
    OPOSMSR.DeviceEnabled := False;
    OPOSMSR.ReleaseDevice;
    OPOSMSR.Close;
  except
  end;
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from TermPorts where TerminalNo = ' + IntToStr(ThisTerminalNo) );
      SQL.Add(' and DeviceNo = 13');
      Open;
      MSROPOSName := FieldByName('OPOSName').AsString;
      Close;
    end;
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  if CheckNCRMSR(MSROPOSName) then
  begin
    OPOSMSR.Open(MSROPOSName);
    OPOSMSR.ClaimDevice(0);
    OPOSMSR.DeviceEnabled := True;
    OPOSMSR.DataEventEnabled := True;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.PartialTender
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    boolean
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.PartialTender : boolean;
var
  sd : pSalesData;
  j : byte;
  RetVal : boolean;
begin
  RetVal := false;
  for j := 0 to CurSaleList.Count - 1 do
  begin
    sd := CurSaleList.Items[j];
    if sd^.LineType = 'MED' then
    begin
      RetVal := true;
      break;
    end;
  end;
  PartialTender := RetVal;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPos.ProcessKeySCR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPos.ProcessKeySCR;
var
  nDeviceType, nDeviceNo, nDriver, nPort, nData, nStop: short;
  nParity       : TParity;
  sOPOSName : string;
  nBaud, i: integer;
begin
  if length(scannerports) > 0 then
    for i := 0 to pred(length(scannerports)) do
      scannerports[i].open := False;
  case bScannerActive of
  2 :
    begin
      OPOSScanner.DeviceEnabled := False;
      OPOSScanner.ReleaseDevice;
      OPOSScanner.Close;
    end;
  end;
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Select * from TermPorts where TerminalNo = :pTerminalNo and DeviceType = 3');
    parambyname('pTerminalNo').AsString := IntToStr(ThisTerminalNo);
    Open;
    if recordcount > 0 then
    while NOT eof do
    begin
      nDeviceType := FieldByName('DeviceType').AsInteger;
      nDeviceNo := FieldByName('DeviceNo').AsInteger;
      nDriver := FieldByName('Driver').AsInteger;
      sOPOSName := FieldByName('OPOSName').AsString;
      nPort := FieldByName('PortNo').AsInteger;
      nBaud := FieldByName('BaudRate').AsInteger;
      nData := FieldByName('DataBits').AsInteger;
      nStop := FieldByName('StopBits').AsInteger;
      if FieldByName('Parity').AsInteger = 0 then
        nParity := pNone
      else if FieldByName('Parity').AsInteger = 1 then
        nParity := pEven
      else
        nParity := pOdd;
      if nDeviceType = 3 then AssignPorts(nDeviceType, nDeviceNo, nDriver, nPort, nBaud, nData, nStop, nParity, sOPOSName);
      next;
    end;
    Close;
  end;
  fmPOSMsg.Close;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPos.ProcessKeyPOR
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPos.ProcessKeyPOR;
var
  s : string;
  CurPtr : integer;
  OldPrice : currency;
  sd : pSalesData;
begin
  if POSListBox.Items.Count = 0 then exit;
  CurPtr := POSListBox.ItemIndex;   //grab the ptr from the item highlighted in the list box
  if CurPtr > (POSListBox.Items.Count - 4) then
    CurPtr := POSListBox.Items.Count - 4;

  sd := CurSaleList.Items[CurPtr];
  sd^.PriceOverridden := true;
  //20070312... Allow price overides for returns (Promotion support)
  if (sd^.SaleType <> 'Sale')
     {$IFDEF PDI_PROMOS}
     and (sd^.SaleType <> 'Rtrn')
     {$ENDIF}
    then
  //...20070312
    Exit;
  if sd^.LineVoided = True then
    Exit;
  if sd^.LineType = 'FUL' then
    Exit;
  fmPriceOverride.fldPrice.text := '';
  fmPriceOverride.show;
  while fmPriceOverride.Visible do
  begin
    Application.ProcessMessages;
    sleep(20);
  end;
  if (fmPriceOverride.fldPrice.text <> '') and
    (sd^.Price <> strtocurr(fmPriceOverride.fldPrice.text)/100) then
  begin
    OldPrice := abs(sd^.ExtPrice);
    sd^.Price := strtocurr(fmPriceOverride.fldPrice.text)/100;
    sd^.ExtPrice := sd^.Qty * sd^.Price;
    s := 'B' + Format('%-20s',[sd^.Name])  + ' ' +
          Format('%3s',[(FormatFloat('###',sd^.Qty))])  + ' ' +
          Format('%9s',[(FormatFloat('#,###.00 ;#,###.00-',sd^.ExtPrice))]);
    s := s + 'POR';
    POSListBox.Items.delete(CurPtr);
    POSListBox.Items.Insert(CurPtr,s);
    ComputeSaleTotal;
    POSListBox.Refresh;
    if not POSDataMod.IBTempTrans1.InTransaction then
      POSDataMod.IBTempTrans1.StartTransaction;
    with POSDataMod.IBTempQry1 do
    begin
      close;SQL.Clear;
      SQL.Add('Update Totals set DLYPORCount = DLYPorCount + 1, ');
      SQL.Add('DLYPORAmount = DLYPORAmount + :pDLYPORAmount');
      SQL.Add('WHERE ((TotalNo = 0) Or ((ShiftNo = :pShiftNo) and (TerminalNo = :pTerminalNo)))');
      ParamByName('pShiftNo').AsInteger := nShiftNo;
      ParamByName('pTerminalNo').AsInteger := fmPOS.ThisTerminalNo;
      parambyname('pDLYPORAmount').AsString := currtostr(sd^.Extprice - OldPrice);
      try
        ExecSQL;
        POSDataMod.IBTempTrans1.Commit;
      except
        on E : Exception do
        begin
          POSDataMod.IBTempTrans1.Rollback;
          UpdateExceptLog('Rollback Price Override Update in Totals ' + e.message);
        end;
      end;
    end;
  end;
end;
//Build 18


{-----------------------------------------------------------------------------
  Name:      TfmPOS.OPOSScannerErrorEvent
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; ResultCode, ResultCodeExtended, ErrorLocus: Integer; var pErrorResponse: Integer
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.OPOSScannerErrorEvent(Sender: TObject; ResultCode,
  ResultCodeExtended, ErrorLocus: Integer; var pErrorResponse: Integer);
var
  sOPOSName : string;
begin
  UpdateExceptLog('Scanner Error');
  OPOSScanner.DeviceEnabled := False;
  try
    OPOSScanner.ReleaseDevice;
    OPOSScanner.Close;
  except
  end;
  if not POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
    begin
      Close;
      SQL.Clear;
      SQL.Add('Select * from TermPorts where TerminalNo = ' + IntToStr(ThisTerminalNo) );
      SQL.Add(' and DeviceNo = 7');
      Open;
      sOPOSName := FieldByName('OPOSName').AsString;
      Close;
    end;
  if POSDataMod.IBTransaction.InTransaction then
      POSDataMod.IBTransaction.Commit;
  OPOSScanner.Open(sOPOSName);
  OPOSScanner.ClaimDevice(0);
  OPOSScanner.DeviceEnabled := True;
  OPOSScanner.DataEventEnabled := True;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ReceiptEventsGotPrinterError
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; const Error: WideString
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
procedure TfmPOS.ReceiptEventsGotPrinterError(Sender: TObject;
  const Error: WideString);
var
  ReceiptErrorMsg            : pReceiptErrorMsg;
begin
  if fmPOSErrorMsg.Visible = False then
 begin
   New(ReceiptErrorMsg);
   ReceiptErrorMsg.Text := Error;
   PostMessage(fmPOS.Handle, WM_RECEIPTERRORMSG, 0, LongInt(ReceiptErrorMsg));
 end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CarWashEventsGotMsgEvent
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; const Dest: WideString; TerminalNo: Integer; const Msg: WideString
  Result:    None
  Purpose:   
-----------------------------------------------------------------------------}
//procedure TfmPOS.CarWashEventsGotMsgEvent(Sender: TObject;
//  const Dest: WideString; TerminalNo: Integer; const Msg: WideString);
//var
//  MsgDest : string;
//  MsgIn : string;
//begin
//  MsgDest := Dest;
//  if (MsgDest = 'POS') and (TerminalNo = ThisTerminalNo) then
//  begin
//    MsgIn := Msg;
//    CWSocketReceiveMessage(Dest, TerminalNo, MsgIn);
//  end;
//end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CreditHostReal
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const CreditAuthType : integer
  Result:    boolean
  Purpose:
-----------------------------------------------------------------------------}
function TfmPOS.CreditHostReal(const CreditAuthType : integer) : boolean;
{Determines if credit host indicated is supported (and not simulated).}
begin
  CreditHostReal := (nCreditAuthType in [CDTSRV_ADS, CDTSRV_NBS, CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD, CDTSRV_LYNK]);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.CreditHostAllowsTotals
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: const CreditAuthType : integer
  Result:    boolean
  Purpose:   
-----------------------------------------------------------------------------}
function TfmPOS.CreditHostAllowsTotals(const CreditAuthType : integer) : boolean;
{Determines if credit host indicated supports a totals request.}
begin
  CreditHostAllowsTotals := (nCreditAuthType in [CDTSRV_BUYPASS, CDTSRV_FIFTH_THIRD, CDTSRV_LYNK]);
end;




{-----------------------------------------------------------------------------
  Name:      TfmPOS.CreditEventsGotPOSMsg
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: Sender: TObject; TerminalNo: Integer; const Msg: WideString
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.CreditEventsGotPOSMsg(Sender: TObject;      // madhu check credit data 21-11-2017
  TerminalNo: Integer; const Msg: WideString);
var
  OutCCData : pCCData;
begin
  //20050217
  //CCSocketReceiveMessage('POS', TerminalNo, Msg) ; // madhu gv after check pls comment this line : 24-11-2017
  New(OutCCData);
  OutCCData^.Orig := 'POS';
  OutCCData^.Msg := Msg;
  OutCCData^.TerminalNo := TerminalNo;
  CCList.Add(OutCCData);
  PostMessage(fmPOS.Handle,WM_CCMSG,0,0);
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.DisconnectScanner
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.DisconnectScanner;
var
  i : integer;
begin
  if length(scannerports) > 0 then
    for i:= 0 to pred(length(scannerports)) do
      scannerports[i].Open := False;
  case bScannerActive of
  2 :
    begin
      OPOSScanner.DeviceEnabled := False;
      OPOSScanner.ReleaseDevice;
      OPOSScanner.Close;
    end;
  end;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ConnectScanner
  Author:    Gary Whetton
  Date:      13-Apr-2004
  Arguments: None
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ConnectScanner;
var
  nDeviceType, nDeviceNo, nDriver, nPort, nBaud, nData, nStop: short;
  nParity       : TParity;
  sOPOSName : string;

begin
  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('Select * from TermPorts where TerminalNo = :pTerminalNo and DeviceType = 3');
    parambyname('pTerminalNo').AsString := IntToStr(ThisTerminalNo);
    Open;
    if recordcount > 0 then
    while NOT eof do
    begin
      nDeviceType := FieldByName('DeviceType').AsInteger;
      nDeviceNo := FieldByName('DeviceNo').AsInteger;
      nDriver := FieldByName('Driver').AsInteger;
      sOPOSName := FieldByName('OPOSName').AsString;
      nPort := FieldByName('PortNo').AsInteger;
      nBaud := FieldByName('BaudRate').AsInteger;
      nData := FieldByName('DataBits').AsInteger;
      nStop := FieldByName('StopBits').AsInteger;
      if FieldByName('Parity').AsInteger = 0 then
        nParity := pNone
      else if FieldByName('Parity').AsInteger = 1 then
        nParity := pEven
      else
        nParity := pOdd;
      if nDeviceType = 3 then AssignPorts(nDeviceType, nDeviceNo, nDriver, nPort, nBaud, nData, nStop, nParity, sOPOSName);
      fmPOSMsg.Close;
      next;
    end;
    Close;
  end;
  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;
end;


{-----------------------------------------------------------------------------
  Name:      TfmPos.ProcessCardTotals
  Author:    Gary Whetton
  Purpose:
-----------------------------------------------------------------------------}
//bp...
procedure TfmPos.ProcessCardTotals();
var
  SaveTitle : string;
begin
   UpdateZLog('inside ProcessCardTotals function-tarang');
  //ShowMessage('inside ProcessCardTotals function'); // madhu remove
  // Send request to activate each card.
  SaveTitle := fmNBSCCForm.Caption;
  fmNBSCCForm.Caption := 'Card totals request.';
  fmNBSCCForm.lStatus.Caption := 'Enter date code.';
  fmNBSCCForm.CurrentTransNo := 0;  // Used to match responses from credit server.
  fmNBSCCForm.Authorized              := 0;
  fmNBSCCForm.AmountDue               := 0.0;
  fmNBSCCForm.TaxAmount               := 0.0;
  fmNBSCCForm.ChargeAmount            := 0.0;
  //DSG
  { FIXME
  if fmPOS.bGiftRestrictions then
    fmNBSCCForm.GiftCardRestrictionCode := RC_UNKNOWN
  else
    fmNBSCCForm.GiftCardRestrictionCode := RC_NO_RESTRICTION;
  //fmNBSCCForm.GiftCardRestrictionCode := RC_UNKNOWN;
  //DSG
  }
  bCardTotalsReceived                 := False;
  CardTotalsDateCode                  := '';
  fmNBSCCForm.ShowModal;    // process card totals
   UpdateZLog('before : PostMessage(fmNBSCCForm.Handle, WM_INITSCREEN,0 ,0)-tarang');
  //ShowMessage('before : PostMessage(fmNBSCCForm.Handle, WM_INITSCREEN,0 ,0)'); // madhu remove
  PostMessage(fmNBSCCForm.Handle, WM_INITSCREEN,0 ,0);

  if CheckNCRMSR(MSROPOSName) then
  begin
    OPOSMSR.DeviceEnabled := True;
    OPOSMSR.DataEventEnabled := True;
  end;
  qClient^.ActivateTransNo := curSale.nTransNo;
  fmNBSCCForm.Caption := SaveTitle;
  if ((bCardTotalsReceived) and (SaleState = ssNoSale)) then
  begin
    //bpc...
    HostTotals.CreateDate := Now();
    //...bpc
    //POSPrt.PrintCardTotals(@HostTotals);
    ReportHdr('- Host Totals Information -');  //20071004b
    PrintCardTotals(@HostTotals);
    ReportFtr();    //20071113e
    {$IFDEF HUCKS_REPORTS}  //20071107d...
    // Adjust where reports cut at request of Huck's Data Analysts
    PrintSeq;
    {$ENDIF}  //...20071107d
    //...20071106
  end;
end; // procedure ProcessCardTotals



{-----------------------------------------------------------------------------
  Name:      TfmPos.VoidPriorCredit
  Author:    Gary Whetton
  Arguments: const VoidTransNo : integer; const VoidAmount : currency; const VoidCardNo : string; const bDebitTransaction : boolean
  Result:    boolean
  Purpose:
-----------------------------------------------------------------------------}
function TfmPos.VoidPriorCredit(const VoidTransNo      : integer;
                               const VoidAmount        : currency;
                               const VoidCardNo        : string;
                               const bDebitTransaction : boolean   ) : boolean;
{Void (or reverse) a previous credit authorization for purchase.}
var
  SaveTitle : string;
begin
   UpdateZLog('inside: VoidPriorCredit:-tarang');
  //ShowMessage('inside: VoidPriorCredit:'); // madhu remove
 if (bSuspendedSale) then
    begin
      POSError('Cannot void credit with outstanding suspended sale.');
      VoidPriorCredit := False;
      exit;
  //...bpj
    end;
  SaveTitle := fmNBSCCForm.Caption;
  fmNBSCCForm.Caption := 'Card authorization reversal request.';
  fmNBSCCForm.lStatus.Caption := 'Press void to reverse credit or clear.';
//  qClient^.GiftCardUsage := GC_VOID_CREDIT;
  //bpd...
//  qClient^.CreditTransNo := VoidTransNo;
//  fmNBSCCForm.SetCCClientData(qClient^.CreditTransNo, qClient^.GiftCardUsage);
  fmNBSCCForm.CurrentTransNo := curSale.nTransNo;
  fmNBSCCForm.VoidTransNo := VoidTransNo;  // Used to match responses from credit server.
  //...bpd
  fmNBSCCForm.ChargeAmount            := VoidAmount;
  //FIXMEfmNBSCCForm.CardNo                  := VoidCardNo;
  //fmNBSCCForm.GiftCardCashoutOption   := CO_DEFAULT;
  fmNBSCCForm.Authorized              := 0;
  fmNBSCCForm.AmountDue               := 0.0;
  fmNBSCCForm.TaxAmount               := 0.0;
  { FIXME
  //DSG
  if fmPOS.bGiftRestrictions then
    fmNBSCCForm.GiftCardRestrictionCode := RC_UNKNOWN
  else
    fmNBSCCForm.GiftCardRestrictionCode := RC_NO_RESTRICTION;
  }
  //fmNBSCCForm.GiftCardRestrictionCode := RC_UNKNOWN;
  //DSG
  bCardTotalsReceived                 := False;
  CardTotalsDateCode                  := '';
   UpdateZLog('fmNBSCCForm.ShowModal; void prior credit-tarang');
  //showmessage('fmNBSCCForm.ShowModal;   // void prior credit');
  fmNBSCCForm.ShowModal;   // void prior credit
  PostMessage(fmNBSCCForm.Handle, WM_INITSCREEN,0 ,0);
  if CheckNCRMSR(MSROPOSName) then
  begin
    OPOSMSR.DeviceEnabled := True;
    OPOSMSR.DataEventEnabled := True;
  end;
  qClient^.ActivateTransNo := curSale.nTransNo;
  fmNBSCCForm.Caption := SaveTitle;
  // (todo) - What is the correct response from a reversal?
  VoidPriorCredit := (fmNBSCCForm.Authorized = 1);
//  VoidPriorCredit := True;
end;  // function VoidPriorCredit


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ReDisplayVoidedCreditSale
  Author:    Gary Whetton
  Purpose:
-----------------------------------------------------------------------------}
//bph...
procedure TfmPOS.ReDisplayVoidedCreditSale();
{Re-display a sales transaction with a voided credit authorization so that it can be re-tendered.
The sales transaction is assumed to already be in CurSaleList.}
var
  j : integer;
  sd : pSalesData;
begin

  InitScreen();
  AssignTransNo();
  for j := 0 to (CurSaleList.Count - 1) do
    begin
      sd := CurSaleList.Items[j];
      {$IFDEF FUEL_PRICE_ROLLBACK}
      DisplaySaleList(sd, False);
      {$ELSE}
      DisplaySaleList(sd);
      {$ENDIF}
      ComputeSaleTotal();
    end;

  nCustBDay                := 0;
  nBeforeDate              := 0;
  curSale.nNonTaxable           := 0;
  curSale.nDiscountableTl       := 0;
  nAmount                  := 0;

  SaleState := ssTender;
end;
//...bph
//...bp

{-----------------------------------------------------------------------------
  Name:      TfmPOS.XMDItemVoid
  Author:    Gary Whetton
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.XMDItemVoid(const CurSaleData : pSalesData);
var
  j : integer;
  sd : pSalesData;
begin
  CurSaleData^.LineVoided := True;   { set current record to voided }
  if sLineType = 'XMD' then
  begin
    nQty := CurSaleData^.Qty * -1;
    nAmount := CurSaleData^.Price;
    nExtAmount   := CurSaleData^.ExtPrice * -1;
  end;

  New(sd);
  sd^.SeqNumber := CurSaleList.Count + 1;
  sd^.LineType := 'XMD';    {DPT, PLU, }
  sd^.SaleType := 'Sale';    {Sale, Void, Rtrn, VdVd, VdRt}

  sd^.PumpNo := 0;
  sd^.FuelSaleID := 0;

  sd^.TaxNo   := 0;   // Init Tax Stuff
  sd^.TaxRate := 0;
  sd^.Taxable := 0;
  sd^.Discable := False;
  sd^.FoodStampable := False;
  sd^.FoodStampApplied := 0;

  sd^.WEXCode := 0;
  sd^.PHHCode := 0;
  sd^.IAESCode := 0;
  sd^.VoyagerCode := 0;

  sd^.PLUModifier  := 0;
  sd^.PLUModifierGroup  := 0;
  sd^.DeptNo  := 0;
  sd^.VendorNo  := 0;
  sd^.ProdGrpNo  := 0;
  sd^.LinkedPLUNo  := 0;
  sd^.SplitQty  := 0;
  sd^.SplitPrice  := 0;
  sd^.LinkedPLUNo := 0;
  sd^.AutoDisc := False;
  sd^.QtyUsedForSplitOrMM := 0;

  sd^.Name           := 'Fuel Discount';
  sd^.Number         := nXMDCode;
  sd^.Qty            := nQty - Frac(nQty);
  sd^.Price          := nAmount;
  nExtAmount                  := nAmount * sd^.Qty;
  sd^.ExtPrice       := nExtAmount;
  sd^.Discable       := False;

  sd^.LineVoided     := True;
  sd^.CCAuthCode     := '';
  sd^.CCApprovalCode := '';
  sd^.CCDate         := '';
  sd^.CCTime         := '';
  sd^.CCCardNo       := '';
  sd^.CCCardType     := '';
  //cwa...
//  sd^.CCCardName     := '';
  sd^.CCCardName     := sCarwashAccessCode;  // normally '' (unless a carwash purchase)
  //...cwa
  //cwf...
//  sd^.CCExpDate      := '';
  sd^.CCExpDate      := sCarwashExpDate;  // normally '' (unless a carwash purchase)
  //...cwf
  //Build 23
  sCarwashAccessCode          := '';
  sCarwashExpDate             := '';
  //Build 23
  sd^.CCBatchNo      := '';
  sd^.CCSeqNo        := '';
  sd^.CCEntryType    := '';
  sd^.CCVehicleNo    := '';
  sd^.CCOdometer     := '';
  //Build 18
  sd^.PriceOverridden := false;
  //Build 18

  //bp...
  for j := low(sd^.CCPrintLine) to high(sd^.CCPrintLine) do
    sd^.CCPrintLine[j]   := '';
//  sd^.CCBalance1     := 0.0;
//  sd^.CCBalance2     := 0.0;
  sd^.CCBalance1     := UNKNOWN_BALANCE;
  sd^.CCBalance2     := UNKNOWN_BALANCE;
  sd^.CCBalance3     := UNKNOWN_BALANCE;
  sd^.CCBalance4     := UNKNOWN_BALANCE;
  sd^.CCBalance5     := UNKNOWN_BALANCE;
  sd^.CCBalance6     := UNKNOWN_BALANCE;
  //...53o
  //...lk1
  sd^.CCRequestType  := RT_UNKNOWN;
  sd^.CCAuthID       := CC_AUTHID_UNKNOWN;
  //...bp
  sd^.ActivationState := asActivationDoesNotApply;
  sd^.ActivationTransNo := 0;
  sd^.ActivationTimeout := 0;
  sd^.LineID := GetLineID();
  sd^.ccPIN := '';
  CurSaleList.Capacity := CurSaleList.Count;
  CurSaleList.Add(sd);
  //Gift
  {$IFDEF FUEL_PRICE_ROLLBACK}
  DisplaySaleList(sd, False);
  {$ELSE}
  DisplaySaleList(sd);
  {$ENDIF}
  PoleMdse(sd, SaleState);
  ComputeSaleTotal;
  CheckSaleList;

  //FIXME may need to return __sd__ as result
end;
//XMD

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKioskPLU
  Author:    Gary Whetton
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKioskPLU(const sKeyVal : string ; const sPreset : string);
begin
  ProcessKeyPLU(sKeyVal, sPreset);
end;
//Kiosk


{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyPDO
  Author:    Gary Whetton
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPDO;
var
  PDOSaleData : pSalesData;
  sd : pSalesData;
  ndx : Byte;
begin
  if CurSaleList.Count = 1 then
  begin
    PDOSaleData := CurSaleList.Items[0];
    if PDOSaleData.LineType = 'FUL' then
    begin
      SaleState := ssTender;
      //20071019a
//      MedMediaNo := 999;
      ClearMedia(@Media);
      Media.MediaNo := DRIVE_OFF_MEDIA_NUMBER;
      //10071019a
      Media.Name := 'Drive Off';
      nAmount := PDOSaleData^.ExtPrice;
      {$IFDEF MULTI_TAX}
      AddTaxList;
      {$ENDIF}
      PoleMedia(AddMediaList(@Media));
      bPostingSale := True;
      curSale.nChangeDue := nAmount - curSale.nAmountDue;
      lTotal.Caption := 'Your Change';
      eTotal.Text := Format('%12s',[(FormatFloat('###,###.00 ;###,###.00-',curSale.nChangeDue))]);
      lTotal.Refresh;
      eTotal.Refresh;

      //Build 31
      PinCreditSelect := 0;
      PoleChange(curSale.nChangeDue, curSale.nTotal);
      nTimerCount := 0;

      EmptyReceiptList;

      New(ReceiptData);
      SD    := CurSaleList.Items[0];
      ReceiptData^   := SD^;
      ReceiptData^.receipttext := SD^.receipttext;
      ReceiptList.Capacity := ReceiptList.Count;
      ReceiptList.Add(ReceiptData);

      rcptSale.nFSSubtotal  := curSale.nFSSubtotal;
      rcptSale.nSubtotal    := curSale.nSubtotal;
      rcptSale.nTlTax       := curSale.nTlTax;
      rcptSale.nTotal       := curSale.nTotal;
      rcptSale.nChangeDue   := curSale.nChangeDue;
      rcptSale.nTransNo     := curSale.nTransNo;
      nRcptShiftNo     := nShiftNo;

      PostSaleList.Clear;
      PostSaleList.Capacity := PostSaleList.Count;
      for ndx := 0 to CurSaleList.Count - 1 do
        PostSaleList.Add(CurSaleList.Items[ndx]);

      pstSale.nNonTaxable      := curSale.nNonTaxable;
      pstSale.nFSSubtotal      := curSale.nFSSubtotal;
      pstSale.nSubtotal        := curSale.nSubtotal;
      pstSale.nTlTax           := curSale.nTlTax;
      pstSale.nTotal           := curSale.nTotal;
      //Gift
      pstSale.nMedia           := 999;
      //Gift
      pstSale.nChangeDue       := curSale.nChangeDue;
      pstSale.nTransNo         := curSale.nTransNo;
      pstSale.nDiscountableTl  := curSale.nDiscountableTl;
      pstSale.nFSChange        := curSale.nFSChange;
      pstSale.nAmountDue       := curSale.nAmountDue;



      POSPost.PostSale(PostSaleList);

      Receipt.SaveSale(PostSaleList);

      Receipt.SaveSaleToText(PostSaleList);

      POSLog.LogSale(PostSaleList);
      DisposeSalesListItems(PostSaleList); // Items on PostSaleList are same as on CurSaleList, so this disposes both.

      CurSaleList.Clear;
      CurSaleList.Capacity := CurSaleList.Count;
      PostSaleList.Clear;
      PostSaleList.Capacity := PostSaleList.Count;
      pstSale.nNonTaxable      := 0;
      pstSale.nFSSubtotal      := 0;
      pstSale.nSubtotal        := 0;
      pstSale.nTlTax           := 0;
      pstSale.nTotal           := 0;
      pstSale.nChangeDue       := 0;
      pstSale.nTransNo         := 0;
      pstSale.nDiscountableTl  := 0;
      pstSale.nFSChange        := 0;
      pstSale.nAmountDue       := 0;


      PrintReceiptFromReceiptList(ReceiptList);
      EmptyReceiptList;
      bSaleComplete := True;
      bPostingSale := False;

      SaleState := ssNoSale;


      SetNextDollarKeyCaption;
      lbReturn.Visible := False;

      nCurMenu := 0;
      DisplayMenu(nCurMenu);
      bCaptureNFPLU := False;
      bNeedModifier := False;

    end;
  end
  else
    POSError('Only Drive Off Allowed In Sale Window');
end;

//dma...
{-----------------------------------------------------------------------------
  Name:      TfmPOS.DebitBINQualify
  Author:    Gary Whetton
  Arguments: const PurchaseAmount : currency; const BINCardType : string
  Result:    boolean
  Purpose:
  History:
-----------------------------------------------------------------------------}
function TfmPOS.DebitBINQualify(const PurchaseAmount : currency; const BINCardType : string) : boolean;
{
Determine if a transaction qualifies to run as PIN debit without prompting for payment type.
The caller has already determined that the card number qualifies for debit BIN manaagement.
}
var
//  DebitMngtCutoff : currency;
  bFoundCreditInterchange : boolean;
  bTryDebit : boolean;
  CreditRate : double;
  CreditFee : double;
  DebitRate : double;
  DebitFee : double;
begin
UpdateZLog('inside :DebitBINQualify function-tarang');
  //ShowMessage('inside :DebitBINQualify function'); // madhu remove
  //bTryDebit := False;
   bTryDebit := (BINCardType = CT_DEBIT);  // default value   //20040812
  // Attempt to extract the interchange rates from the database to determine the cheaper method (debit vs credit)
  try
    if not POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.StartTransaction;
    with POSDataMod.IBTempQuery do
      begin
        Close;
        SQL.Clear;
//        SQL.Add('Select DebitMngtCutoff from Setup');
//        Open;
//        DebitMngtCutoff := FieldByName('DebitMngtCutoff').AsCurrency;
        SQL.Add('Select * from ccInterchangeRates where CardType = :pCardType and OutsideFlag = 0 and DebitFlag = 0');
        ParamByName('pCardType').AsString := BINCardType;
        Open;
        bFoundCreditInterchange := (RecordCount > 0);
        if (bFoundCreditInterchange) then
        begin
          CreditRate := FieldByName('SaleRate').AsCurrency + FieldByName('AssesmentRate').AsCurrency;
          CreditFee  := FieldByName('TransFee').AsCurrency + FieldByName('BaseIIFee').AsCurrency;
        end
        else
        begin
          CreditRate := 0.0;  // not used, but prevents compiler warning
          CreditFee  := 0.0;  // not used, but prevents compiler warning
        end;
        Close;
        if (bFoundCreditInterchange) then
        begin
          SQL.Clear;
          SQL.Add('Select * from ccInterchangeRates where CardType = :pCardType and OutsideFlag = 0 and DebitFlag = 1');
          ParamByName('pCardType').AsString := BINCardType;
          Open;
          if (RecordCount > 0) then
          begin
            DebitRate := FieldByName('SaleRate').AsCurrency + FieldByName('AssesmentRate').AsCurrency;
            DebitFee  := FieldByName('TransFee').AsCurrency + FieldByName('BaseIIFee').AsCurrency;
            // See if debit would be cheaper than credit for this transaction
            bTryDebit := ((DebitRate * PurchaseAmount + DebitFee) < (CreditRate * PurchaseAmount + CreditFee));
          end;
          Close;
        end;
      end;
    if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
//    DebitBINQualify := (PurchaseAmount >= DebitMngtCutoff);
  except
    UpdateExceptLog('Cannot access interchange rates from DB');
//    DebitBINQualify := False;
  end;
  DebitBINQualify := bTryDebit;
end;
//...dma


//Mega Suspend
{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeySR2
  Author:    Gary Whetton
  Purpose:
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeySR2;
var
  ndx : Byte;
  j : integer;
  SUS : pSalesData;
  {$IFDEF CISP_CODE}
  {$IFNDEF CISP_WIDE_FIELDS}  //20060924a
  StringToEncrypt : string;
  {$ENDIF}
  {$ENDIF}
  CurSaleData : pSalesData;
begin
  UpdateZLog('inside ProcessKeySR2 function-tarang');
  //ShowMessage('inside ProcessKeySR2 function'); // madhu remove
  if (sEntry <> '') and (CurSaleList.Count <= 0) then
  begin
    if not POSDataMod.IBSuspendTrans.InTransaction then
    POSDataMod.IBSuspendTrans.StartTransaction;
    with POSDataMod.IBSuspendQry do
    begin
      Close;SQL.Clear;
      SQL.Add('Select * from SuspendSale where TransactionNo = :pTransNo order by SeqNumber');
      parambyname('pTransNo').AsString := trim(sEntry);
      Open;
      if RecordCount > 0 then
      begin
        while not eof do
        begin
          New(CurSaleData);
          ZeroMemory(CurSaleData, sizeof(TSalesData));
          curSale.nTransNo := fieldByName('TransactionNo').AsInteger;
          CurSaleData^.SeqNumber := fieldByName('SeqNumber').AsInteger;
          CurSaleData^.LineType := fieldByName('LineType').AsString;
          CurSaleData^.SaleType := fieldByName('SaleType').AsString;
          CurSaleData^.Number := fieldByName('SaleNo').AsCurrency;
          CurSaleData^.Name := fieldByName('SaleName').AsString;
          CurSaleData^.Qty := fieldByName('Qty').AsCurrency;
          CurSaleData^.Price := fieldByName('Price').AsCurrency;
          CurSaleData^.ExtPrice := fieldByName('ExtPrice').AsCurrency;
          CurSaleData^.SavDiscable := fieldByName('SavDiscable').AsCurrency;
          CurSaleData^.SavDiscAmount := fieldByName('SavDiscAmount').AsCurrency;
          CurSaleData^.PumpNo := fieldByName('PumpNo').AsInteger;
          CurSaleData^.HoseNo := fieldByName('HoseNo').AsInteger;
          CurSaleData^.FuelSaleID := fieldByName('FuelSaleID').AsInteger;

          CurSaleData^.TaxNo := fieldByName('TaxNo').AsInteger;
          CurSaleData^.TaxRate := fieldByName('TaxRate').AsCurrency;
          CurSaleData^.Taxable := fieldByName('Taxable').AsCurrency;
          CurSaleData^.Discable := boolean(fieldByName('Disc').AsInteger);
          CurSaleData^.LineVoided := Boolean(fieldByName('Linevoided').AsInteger);

          CurSaleData^.WEXCode := fieldByName('WEXCode').AsInteger;
          CurSaleData^.PHHCode := fieldByName('PHHCode').AsInteger;
          CurSaleData^.IAESCode := fieldByName('IAESCode').AsInteger;
          CurSaleData^.VoyagerCode := fieldByName('VoyagerCode').AsInteger;

          CurSaleData^.CCAuthCode := fieldByName('CCAuthCode').AsString;
          CurSaleData^.CCApprovalCode := fieldByName('CCApprovalCode').AsString;
          CurSaleData^.CCDate := fieldByName('CCDate').AsString;
          CurSaleData^.CCTime := fieldByName('CCTime').AsString;

          {$IFDEF CISP_CODE}
          if (fmPOS.UseCISPEncryption(Setup.CreditAuthType)) then
          begin
            // Note:  Field for ccCardNo is to short to encrypt.  Once field is widened, it can be encrypted.
            {$IFDEF CISP_WIDE_FIELDS}  //20060924a
            CurSaleData^.CCCardNo := DecryptString(FieldbyName('CCCardNo').AsString);
            {$ELSE}
            CurSaleData^.CCCardNo := FieldbyName('CCCardNo').AsString;
            {$ENDIF}
            CurSaleData^.CCCardName := DecryptString(FieldbyName('CCCardName').AsString);
            CurSaleData^.CCExpDate := DecryptString(FieldByName('CCExpDate').AsString);
            Free();
          end
          else
          {$ENDIF}
          begin
            CurSaleData^.CCCardNo := fieldByName('CCCardNo').AsString;
            CurSaleData^.CCCardName := fieldByName('CCCardName').AsString;
            CurSaleData^.CCExpDate := fieldByName('CCExpDate').AsString;
          end;
          CurSaleData^.CCCardType := fieldByName('CCCardType').AsString;
          CurSaleData^.CCBatchNo := fieldByName('CCBatchNo').AsString;
          CurSaleData^.CCSeqNo := fieldByName('CCSeqNo').AsString;
          CurSaleData^.CCEntryType := fieldByName('CCEntryType').AsString;
          CurSaleData^.CCVehicleNo := Trim(fieldByName('CCVehicleNo').AsString);  //20060906c (added trim)
          CurSaleData^.CCOdometer := Trim(fieldByName('CCOdometer').AsString);    //20060906c (added trim)
          for j := low(CurSaleData^.CCPrintLine) to high(CurSaleData^.CCPrintLine) do
            CurSaleData^.CCPrintLine[j] := fieldByName('CCPrintLine' + IntToStr(j)).AsString;
          CurSaleData^.CCBalance1 := fieldByName('CCBalance1').AsCurrency;
          CurSaleData^.CCBalance2 := fieldByName('CCBalance2').AsCurrency;
          CurSaleData^.CCBalance3 := fieldByName('CCBalance3').AsCurrency;
          CurSaleData^.CCBalance4 := fieldByName('CCBalance4').AsCurrency;
          CurSaleData^.CCBalance5 := fieldByName('CCBalance5').AsCurrency;
          CurSaleData^.CCBalance6 := fieldByName('CCBalance6').AsCurrency;
          CurSaleData^.CCRequestType := fieldByName('CCRequestType').AsInteger;
          CurSaleData^.CCAuthID     := fieldByName('CCAuthid').AsInteger;
          CurSaleData^.CCAuthorizer := fieldByName('CCAuthorizer').AsString;
          CurSaleData^.PLUModifier := FieldByName('PLUModifier').AsInteger;
          CurSaleData^.PLUModifierGroup := FieldByName('PLUModifierGroup').AsCurrency;

          try
            CurSaleData^.ActivationState := TActivationState(FieldByName('ActivationState').AsInteger);  // asActivationDoesNotApply;
          except
            CurSaleData^.ActivationState := asActivationDoesNotApply;
          end;
          CurSaleData^.ActivationTransNo := FieldByName('ActivationTransNo').AsInteger;
          CurSaleData^.ActivationTimeout := FieldByName('ActivationTimeout').AsDateTime;
          CurSaleData^.LineID := FieldByName('LineID').AsInteger;
          CurSaleData^.ccPIN := FieldByName('CCPIN').AsString;
          CurSaleList.Capacity := CurSaleList.Count;
          CurSaleList.Add(CurSaleData);
          fmPOS.DisplaySuspend(CurSaleData);
          Next;
        end;
        Close;SQL.Clear;
        SQL.Add('Delete from SuspendSale where TransactionNo = :pTransNo');
        parambyname('pTransNo').AsInteger := curSale.nTransNo;
        ExecSQL;
      end
      else
        ClearEntryField;
    end;
    if POSDataMod.IBSuspendTrans.InTransaction then
      POSDataMod.IBSuspendTrans.Commit;
  end
  else if CurSaleList.Count <= 0 then
  begin
    fmSuspend := TfmSuspend.Create(Self);
    fmSuspend.ShowModal;
    fmSuspend.Release;
  end
  else if SaleState = ssSale then
  begin
    for ndx := 0 to CurSaleList.Count - 1 do
    begin
      SUS := CurSaleList.Items[ndx];
      if not POSDataMod.IBSuspendTrans.InTransaction then
      POSDataMod.IBSuspendTrans.StartTransaction;
      with POSDataMod.IBSuspendQry do
      begin
        Close;SQL.Clear;
        SQL.Add('Insert into SuspendSale (TransactionNo, SeqNumber, LineType, SaleType, ');
        SQL.Add('SaleNo, SaleName, Qty, Price, ExtPrice, SavDiscable, SavDiscAmount,');
        SQL.Add('PumpNo, HoseNo, Disc, Subtotal, TlTotal, Total, ChangeDue, LineVoided, ');
        SQL.Add('TaxNo, TaxRate, Taxable, WEXCode, PHHCode, IAESCode, VoyagerCode, ');
        SQL.Add('CCAuthCode, CCApprovalCode, CCDate, CCTime, CCCardNo, CCCardType, ');
        SQL.Add('CCCardName, CCExpDate, CCBatchNo, CCSeqNo, CCEntryType, CCvehicleNo, ');
        SQL.Add('CCOdometer, CCPrintLine1, CCPrintLine2, CCPrintLine3, CCPrintLine4, ');
        SQL.Add('CCBalance1, CCBalance2, CCBalance3, CCBalance4, CCBalance5, CCBalance6, ');
        SQL.Add('ActivationState, ActivationTransNo, ActivationTimeout, LineID, CCPin, ');
        SQL.Add('CCRequestType, CCAuthID, CCAuthorizer, FuelSaleID, PLUModifier, PLUModifierGroup) Values ');
        SQL.Add('(:pTransactionNo, :pSeqNumber, :pLineType, :pSaleType, ');
        SQL.Add(':pSaleNo, :pSaleName, :pQty, :pPrice, :pExtPrice, :pSavDiscable, :pSavDiscAmount,');
        SQL.Add(':pPumpNo, :pHoseNo, :pDisc, :pSubtotal, :pTlTotal, :pTotal, :pChangeDue, :pLineVoided, ');
        SQL.Add(':pTaxNo, :pTaxRate, :pTaxable, :pWEXCode, :pPHHCode, :pIAESCode, :pVoyagerCode, ');
        SQL.Add(':pCCAuthCode, :pCCApprovalCode, :pCCDate, :pCCTime, :pCCCardNo, :pCCCardType, ');
        SQL.Add(':pCCCardName, :pCCExpDate, :pCCBatchNo, :pCCSeqNo, :pCCEntryType, :pCCvehicleNo, ');
        SQL.Add(':pCCOdometer, :pCCPrintLine1, :pCCPrintLine2, :pCCPrintLine3, :pCCPrintLine4, ');
        SQL.Add(':pCCBalance1, :pCCBalance2, :pCCBalance3,  :pCCBalance4, :pCCBalance5,   :pCCBalance6, ');
        SQL.Add(':pActivationState, :pActivationTransNo, :pActivationTimeout, :pLineID, :pCCPin, ');
        SQL.Add(':pCCRequestType, :pCCAuthID, :pCCAuthorizer, :pFuelSaleID, :pPLUMod, :pPLUModGrp)');

        ParamByName('pTransactionNo').AsInteger    := curSale.nTransNo;
        ParamByName('pSeqNumber').AsInteger        := SUS^.SeqNumber;
        ParamByName('pLineType').AsString          := SUS^.LineType;
        ParamByName('pSaleType').AsString          := SUS^.SaleType;
        ParamByName('pSaleNo').AsCurrency             := SUS^.Number;
        ParamByName('pSaleName').AsString          := SUS^.Name;
        ParamByName('pQty').AsCurrency             := SUS^.Qty;
        ParamByName('pPrice').AsCurrency           := SUS^.Price;
        ParamByName('pExtPrice').AsCurrency        := SUS^.ExtPrice;
        ParamByName('pSavDiscable').AsCurrency     := SUS^.SavDiscable;
        ParamByName('pSavDiscAmount').AsCurrency   := SUS^.SavDiscAmount;
        ParamByName('pPumpNo').AsInteger           := SUS^.PumpNo;
        ParamByName('pHoseNo').AsInteger           := SUS^.HoseNo;
        ParamByName('pFuelSaleID').AsInteger       := SUS^.FuelSaleID;

        ParamByName('pTaxNo').AsInteger            := SUS^.TaxNo;
        ParamByName('pTaxRate').AsCurrency         := SUS^.TaxRate;
        ParamByName('pTaxable').AsCurrency         := SUS^.Taxable;
        ParamByName('pDisc').AsInteger             := Integer(SUS^.Discable);
        ParamByName('pLinevoided').AsInteger       := Integer(SUS^.LineVoided);

        ParamByName('pSubTotal').AsCurrency        := pstSale.nSubTotal;
        ParamByName('pTlTotal').AsCurrency         := pstSale.nTlTax;
        ParamByName('pTotal').AsCurrency           := pstSale.nTotal;
        ParamByName('pChangeDue').AsCurrency       := pstSale.nChangeDue;

        ParamByName('pWEXCode').AsInteger          := SUS^.WEXCode;
        ParamByName('pPHHCode').AsInteger          := SUS^.PHHCode;
        ParamByName('pIAESCode').AsInteger         := SUS^.IAESCode;
        ParamByName('pVoyagerCode').AsInteger      := SUS^.VoyagerCode;

        ParamByName('pCCAuthCode').AsString        := SUS^.CCAuthCode;
        ParamByName('pCCApprovalCode').AsString    := SUS^.CCApprovalCode;
        ParamByName('pCCDate').AsString            := SUS^.CCDate;
        ParamByName('pCCTime').AsString            := SUS^.CCTime;
        {$IFDEF CISP_CODE}
        if (fmPOS.UseCISPEncryption(Setup.CreditAuthType)) then
        begin
          {$IFDEF CISP_WIDE_FIELDS}  //20060924a
          ParamByName('pCCCardNo').AsString          := EncryptString(Copy(SUS^.CCCardNo,   1, MAX_DB_LEN_RECEIPT_CCCARD_NO));
          ParamByName('pCCCardName').AsString        := EncryptString(Copy(SUS^.CCCardName, 1, MAX_DB_LEN_RECEIPT_CC_CARD_NAME));
          ParamByName('pCCExpDate').AsString         := EncryptString(Copy(SUS^.CCExpDate,  1, MAX_DB_LEN_EXP_DATE));
          {$ELSE}
          // Note:  Field for ccCardNo is to short to encrypt.  Once field is widened, it can be encrypted.
          if (SUS^.CCCardType <> CT_GIFT) then  // The gift card number may be needed for subsequent voiding.
            ParamByName('pCCCardNo').AsString          := MaskCardNumber(SUS^.CCCardNo)
          else
            ParamByName('pCCCardNo').AsString          := SUS^.CCCardNo;
          StringToEncrypt := SUS^.CCCardName;
          ParamByName('pCCCardName').AsString        := EncryptString(Copy(StringToEncrypt, 1, MAX_XX_LEN_RECEIPT_CC_CARD_NAME));
          StringToEncrypt := SUS^.CCExpDate;
          ParamByName('pCCExpDate').AsString         := EncryptString(Copy(StringToEncrypt, 1, MAX_XX_LEN_EXP_DATE));
          {$ENDIF}  //CISP_WIDE_FIELDS
        end
        else
        {$ENDIF} //CISP_CODE
        begin
          ParamByName('pCCCardNo').AsString          := SUS^.CCCardNo;
          ParamByName('pCCCardName').AsString        := SUS^.CCCardName;
          ParamByName('pCCExpDate').AsString         := SUS^.CCExpDate;
        end;
        ParamByName('pCCCardType').AsString        := SUS^.CCCardType;
        ParamByName('pCCBatchNo').AsString         := SUS^.CCBatchNo;
        ParamByName('pCCSeqNo').AsString           := SUS^.CCSeqNo;
        ParamByName('pCCEntryType').AsString       := SUS^.CCEntryType;
        ParamByName('pCCVehicleNo').AsString       := SUS^.CCVehicleNo;
        ParamByName('pCCOdometer').AsString        := SUS^.CCOdometer;
        //bp...
        for j := low(SUS^.CCPrintLine) to high(SUS^.CCPrintLine) do
          ParamByName('pCCPrintLine' + IntToStr(j)).AsString      := SUS^.CCPrintLine[j];
        ParamByName('pCCBalance1').AsCurrency      := SUS^.CCBalance1;
        ParamByName('pCCBalance2').AsCurrency      := SUS^.CCBalance2;
        ParamByName('pCCBalance3').AsCurrency      := SUS^.CCBalance3;
        ParamByName('pCCBalance4').AsCurrency      := SUS^.CCBalance4;
        ParamByName('pCCBalance5').AsCurrency      := SUS^.CCBalance5;
        ParamByName('pCCBalance6').AsCurrency      := SUS^.CCBalance6;
        //...lya
        ParamByName('pActivationState').AsInteger    := Integer(SUS^.ActivationState);
        ParamByName('pActivationTransNo').AsInteger  := SUS^.ActivationTransNo;
        ParamByName('pActivationTimeout').AsDateTime := SUS^.ActivationTimeout;
        ParamByName('pLineID').AsInteger             := SUS^.LineID;
        ParamByName('pCCPin').AsString               := SUS^.ccPIN;
        ParamByName('pCCRequestType').AsInteger    := SUS^.CCRequestType;
        ParamByName('pCCAuthID').AsInteger         := SUS^.CCAuthID;
        ParamByName('pCCAuthorizer').AsString      := SUS^.CCAuthorizer;
        parambyname('pPLUMod').AsInteger           := SUS^.PLUModifier;
        parambyname('pPLUModGrp').AsCurrency          := SUS^.PLUModifierGroup;
        //...bp
        try
          ExecSQL;
          if POSDataMod.IBSuspendTrans.InTransaction then
            POSDataMod.IBSuspendTrans.Commit;
        except
          on E : Exception do
          begin
            UpdateExceptLog( 'Insert Suspend Table ' + e.message);
            if POSDataMod.IBSuspendTrans.InTransaction then
              POSDataMod.IBSuspendTrans.Rollback;
            break;
          end
          else
          begin
            if POSDataMod.IBSuspendTrans.InTransaction then
              POSDataMod.IBSuspendTrans.Rollback;
            break;
          end;
        end;//try..except
      end;
    end;
    LogSuspend;
    InitScreen;
    CurSaleList.Clear;
    CurSaleList.Capacity := CurSaleList.Count;
  end
  else
    POSError('Cannot Suspend After Tender');
end;

{-----------------------------------------------------------------------------
  Procedure: DisplaySuspend
  Author:    Gary Whetton
  Purpose:   Takes data from suspend table and displays in sale list
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.DisplaySuspend(const CurSaleData : pSalesData);
begin
  SaleState := ssSale;
  {$IFDEF FUEL_PRICE_ROLLBACK}
  DisplaySaleList(CurSaleData, False);
  {$ELSE}
  DisplaySaleList(CurSaleData);
  {$ENDIF}
  ComputeSaleTotal;
end;

{-----------------------------------------------------------------------------
  Procedure: ProcessKeyPBL
  Author:    Gary Whetton
  Purpose:   Print data in sales list
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyPBL;
begin
  rcptSale.nFSSubtotal  := curSale.nFSSubtotal;  //20060913a Get Current FS total
  rcptSale.nSubtotal  := curSale.nSubtotal;
  rcptSale.nTlTax     := curSale.nTlTax;
  rcptSale.nTotal     := curSale.nTotal;
  rcptSale.nChangeDue := curSale.nChangeDue;
  nRcptShiftNo   := nShiftNo;
  PrintBill;
end;
//Mega Suspend

//gift-20040708...
{-----------------------------------------------------------------------------
  Function:  EncodeGiftCardInfoInDeptName
  Author:    Ron Payne
  Purpose:
  Arguments: const sd : pSalesData
  Result:    string
  History:
-----------------------------------------------------------------------------}
function TfmPOS.EncodeGiftCardInfoInDeptName(const sd : pSalesData) : string;
{
  Make the department name for gift card entries also show the last digits of the card number.
  Caller has already verified that entry is a gift card department (although, no change would
  be made to the department name if called for a non-gift department).
}
var
  RetStr : string;
  CardNo : string;
  LastDigits : string;
  LenCardNo : integer;
  LenMSRData : integer;
  idxEqualSign : integer;
  idxSemicolon : integer;
  idxEnd : integer;
  Track2Data : string;
begin
  RetStr := sd^.Name;
  // If credit interface has already set card number, then just use it.
  CardNo := Trim(ActivationProductData.ActivationCardNo);
  if (CardNo = '') then
  begin
    // Credit interface has not set card number yet.  Try to extract from MSR data.
    LenMSRData := Length(ActivationProductData.ActivationMSR);
    idxSemicolon := POS(';', ActivationProductData.ActivationMSR);
    if (idxSemicolon > 0) then
    begin
      Track2Data := Copy(ActivationProductData.ActivationMSR, idxSemicolon, LenMSRData - idxSemicolon + 1);
      idxEqualSign := POS('=', Track2Data);
      if (idxEqualSign > 0) then idxEnd := idxEqualSign   // standard track 2 format
      else                       idxEnd := Length(Track2Data);  // Thornton gift card - just card number
      CardNo := Copy(Track2Data, 2, idxEnd - 2);
    end;
  end;
  // Append the last digits of the card number to the department name.
  LenCardNo := Length(CardNo);
  if (LenCardNo >= nPANNonTruncatedCustomerCopy) then
  begin
    LastDigits := ' # ' + RightStr(CardNo, nPANNonTruncatedCustomerCopy);
    if ((POS(LastDigits, RetStr) <= 0) and ((Length(RetStr) + Length(LastDigits)) < SizeOf(sd^.Name))) then
      RetStr := RetStr + LastDigits;
  end;
  EncodeGiftCardInfoInDeptName := RetStr;
end;
//...gift-20040708

//20040827...

{-----------------------------------------------------------------------------
  Function:  AdjustFoodStampChargeAmount
  Author:    Ron Payne
  Purpose:
  Arguments: const AttemptAmount : currency; const AttemptCardType : string
  Result:    currency
  History:
-----------------------------------------------------------------------------}
function TfmPOS.AdjustFoodStampChargeAmount(const AttemptAmount : currency; const AttemptCardType : string) : currency;
{Adjust the charge amount to pass to the credit server to reflect any amounts
that do not qualify for food stamps.}
var
  Amount : currency;
begin
  if ({//20050103...(AttemptAmount > 0) and }(AttemptCardType = CT_EBT_FS)) then
  begin
    // Only allow Food stamp items not already tendered
    //20050103...
    if (AttemptAmount < 0.0) then
      Amount := MAX(AttemptAmount, MIN(curSale.nFSSubtotal - curSale.FoodStampMediaAmount, 0))
    else
    //...20050103
      Amount := MIN(AttemptAmount, MAX(curSale.nFSSubtotal - curSale.FoodStampMediaAmount, 0));
    // Notify clerk if some amounts do not quailfy.
    // Note:  Amount may reduce by exempted tax amount without notification
    if (Amount = 0) then
      fmPOS.POSError('No items qualify for Food Stamp purchase')
    else if ((Amount + curSale.nFSTax) < AttemptAmount) then
      fmPOS.POSError('Note:  Only $' + CurrToStr(Amount) + ' qualifies for Food Stamp EBT account');
  end
  else
  begin
    Amount := AttemptAmount;
  end;
  AdjustFoodStampChargeAmount := Amount;
end;
//...20040827

{$IFDEF DEV_PIN_PAD}
function TfmPOS.ValidateCardInfo(const qValidCardInfo : pValidCardInfo) : boolean;
var
  TryCount : integer;
  RetCode : boolean;
  {$IFDEF FUEL_PRICE_ROLLBACK}
  cCheckAmount : currency;
  {$ENDIF}
begin
   UpdateZLog('inside ValidateCardInfo function-tarang');
  //ShowMessage('inside ValidateCardInfo function'); // madhu remove
  if ((LastValidCardInfo.Track1Data <> qValidCardInfo^.Track1Data) or
      (LastValidCardInfo.Track2Data <> qValidCardInfo^.Track2Data)) then
  begin
    RetCode := False;
    qValidCardInfo^.Orig := 'POSSrvr';
    if (CreditHostReal(nCreditAuthType) and (not bClosingPOS)) then
    begin
      for TryCount := 1 to 5 do
      begin
        try
          RetCode := DCOMCredit.ValidCard(qValidCardInfo^.Orig,
                                          qValidCardInfo^.Track1Data,
                                          qValidCardInfo^.Track2Data,
                                          qValidCardInfo^.CardNo,
                                          qValidCardInfo^.ExpDate,
                                          qValidCardInfo^.ServiceCode,
                                          qValidCardInfo^.CardName,
                                          qValidCardInfo^.VehicleNo,
                                          qValidCardInfo^.CardError,
                                          qValidCardInfo^.CardType,
                                          qValidCardInfo^.CardTypeName,
                                          qValidCardInfo^.iFaceValueCents,
                                          qValidCardInfo^.bActivationType,
                                          qValidCardInfo^.bGetDriverID,
                                          qValidCardInfo^.bGetOdometer,
                                          qValidCardInfo^.bGetRefNo,
                                          qValidCardInfo^.bGetVehicleNo,
                                          qValidCardInfo^.bGetZIPCode,
                                          qValidCardInfo^.bAskDebit,
                                          qValidCardInfo^.bDebitBINMngt);
            if (fmPOS.lbReturn.Visible) then     // Do not prompt for zip code on merchandise returns
              qValidCardInfo^.bGetZIPCode := False;
            if Pos('=', qValidCardInfo^.Track2Data) = 0 then  // Do not ask for debit processing if track 2 not read.
              qValidCardInfo^.bAskDebit := False;
          break;
        except
          on E: Exception do
            ReconnectCredit('ValidateCardInfo', e.message, '', TryCount);
        end;
      end;
    end;
    if (RetCode) then
    begin
      {$IFDEF FUEL_PRICE_ROLLBACK}
      CardType    := wCardType;   // Note:  local variable CardType name was changed to wCardType
      // If payment type selection not required, then verify tender for card type
      // (If payment type must be selected, then this check will be made when customer selects payment type.)
      if (((not bCreditSelectNeeded) or (not bAskDebit)) and
          ((nAmount > 0.0) and (nAmount >= nCurAmountDue)) or ((nAmount = 0.0) and (nCurAmountDue > 0.0))) then
      begin
        if (nAmount > 0.0) then
          cCheckAmount := nAmount
        else
          cCheckAmount := nCurAmountDue;
        if (not AdjustFuelPriceForTender(cCheckAmount, CREDIT_MEDIA_NUMBER, qValidCardInfo^.CardType)) then
        begin
          PinCreditSelect := 0;
          CardNo := '';
          CardType := '';
          DCOMPinPad.ResetData();
          DCOMPinPad.GetSwipe();
          ValidateCardInfo := False;
          exit;  // User rejected alternate pricing for the payment type selected.
        end;
      end;
      {$ENDIF}
      LastValidCardInfo.bSwipeAtPINPad := qValidCardInfo^.bSwipeAtPINPad;
      LastValidCardInfo.Orig           := qValidCardInfo^.Orig;
      LastValidCardInfo.Track1Data     := qValidCardInfo^.Track1Data;
      LastValidCardInfo.Track2Data     := qValidCardInfo^.Track2Data;
      LastValidCardInfo.CardNo         := qValidCardInfo^.CardNo;
      LastValidCardInfo.ExpDate        := qValidCardInfo^.ExpDate;
      LastValidCardInfo.ServiceCode    := qValidCardInfo^.ServiceCode;
      LastValidCardInfo.CardName       := qValidCardInfo^.CardName;
      LastValidCardInfo.VehicleNo      := qValidCardInfo^.VehicleNo;
      LastValidCardInfo.CardError      := qValidCardInfo^.CardError;
      LastValidCardInfo.CardType       := qValidCardInfo^.CardType;
      LastValidCardInfo.CardTypeName   := qValidCardInfo^.CardTypeName;
      LastValidCardInfo.iFaceValueCents := qValidCardInfo^.iFaceValueCents;
      LastValidCardInfo.bActivationType := qValidCardInfo^.bActivationType;
      LastValidCardInfo.bGetDriverID   := qValidCardInfo^.bGetDriverID;
      LastValidCardInfo.bGetOdometer   := qValidCardInfo^.bGetOdometer;
      LastValidCardInfo.bGetRefNo      := qValidCardInfo^.bGetRefNo;
      LastValidCardInfo.bGetVehicleNo  := qValidCardInfo^.bGetVehicleNo;
      LastValidCardInfo.bGetZIPCode    := qValidCardInfo^.bGetZIPCode;
      LastValidCardInfo.bAskDebit      := qValidCardInfo^.bAskDebit;
      LastValidCardInfo.bDebitBINMngt  := qValidCardInfo^.bDebitBINMngt;
    end;
  end
  else   // I.e., the track data matches the last successful call to validate the card info.
  begin
    qValidCardInfo^.bSwipeAtPINPad := LastValidCardInfo.bSwipeAtPINPad;
    qValidCardInfo^.Orig           := LastValidCardInfo.Orig;
    qValidCardInfo^.CardNo         := LastValidCardInfo.CardNo;
    qValidCardInfo^.ExpDate        := LastValidCardInfo.ExpDate;
    qValidCardInfo^.ServiceCode    := LastValidCardInfo.ServiceCode;
    qValidCardInfo^.CardName       := LastValidCardInfo.CardName;
    qValidCardInfo^.VehicleNo      := LastValidCardInfo.VehicleNo;
    qValidCardInfo^.CardError      := LastValidCardInfo.CardError;
    qValidCardInfo^.CardType       := LastValidCardInfo.CardType;
    qValidCardInfo^.CardTypeName   := LastValidCardInfo.CardTypeName;
    qValidCardInfo^.iFaceValueCents := LastValidCardInfo.iFaceValueCents;
    qValidCardInfo^.bActivationType := LastValidCardInfo.bActivationType;
    qValidCardInfo^.bGetDriverID   := LastValidCardInfo.bGetDriverID;
    qValidCardInfo^.bGetOdometer   := LastValidCardInfo.bGetOdometer;
    qValidCardInfo^.bGetRefNo      := LastValidCardInfo.bGetRefNo;
    qValidCardInfo^.bGetVehicleNo  := LastValidCardInfo.bGetVehicleNo;
    qValidCardInfo^.bGetZIPCode    := LastValidCardInfo.bGetZIPCode;
    qValidCardInfo^.bAskDebit      := LastValidCardInfo.bAskDebit;
    qValidCardInfo^.bDebitBINMngt  := LastValidCardInfo.bDebitBINMngt;
    RetCode := True;
  end;
  ValidateCardInfo := RetCode;
    UpdateZLog('END:  ValidateCardInfo function and RetCode-tarang:'+RetCode);
    //ShowMessage('END:  ValidateCardInfo function and RetCode'+RetCode); // madhu remove

end;
{$ENDIF}

{$IFDEF CISP_CODE}
function TfmPOS.MaskCardNumber(const UnMaskedCardNo : string) : string;
const
  MASK_CHARACTERS : string = '********************************';
  DIGITS_NOT_MASKED = 4;
var
   LenCardNo : integer;
   RetLength : integer;
   TrimUnMaskedCardNo : string;
   RetString : string;
begin
  TrimUnMaskedCardNo := Trim(UnMaskedCardNo);
  LenCardNo := Length(TrimUnMaskedCardNo);
  if ((LenCardNo > DIGITS_NOT_MASKED) or (LenCardNo < MAX_DB_LEN_RECEIPT_CCCARD_NO)) then
    RetLength := LenCardNo
  else
    RetLength := MAX_DB_LEN_RECEIPT_CCCARD_NO;
  RetString := Copy(MASK_CHARACTERS,    1,                                 RetLength - DIGITS_NOT_MASKED) +
               Copy(TrimUnMaskedCardNo, LenCardNo - DIGITS_NOT_MASKED + 1, DIGITS_NOT_MASKED);
  MaskCardNumber := RetString;
end;  // function MaskCardNumber

function TfmPOS.UseCISPEncryption(const HostID : integer) : boolean;
begin
  {$IFDEF CISP_WIDE_FIELDS}  //20061019a
  UseCISPEncryption := (HostID in [CDTSRV_NBS,
                                   CDTSRV_BUYPASS,        //20070402a
                                   CDTSRV_FIFTH_THIRD]);
  {$ELSE}
  UseCISPEncryption := (HostID = CDTSRV_FIFTH_THIRD);
  {$ENDIF}
end;  // function UseCISPEncryption


{$ENDIF}  //CISP_CODE

{-----------------------------------------------------------------------------
  Procedure: ReconnectPinPad
  Author:    Gary Whetton
  Purpose:
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.ReconnectPinPad(CalledFrom : string);
begin
end;

{-----------------------------------------------------------------------------
  Procedure: UpdatePinPad
  Author:    Gary Whetton
  Purpose:
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.UpdatePinPad(var Msg : TMessage);
begin
  if FSaleState = ssSale then
  begin
    try
      //dmb...
      //DCOMPinPad.GetPaymentMethod(bGiftPurchase);
      //DCOMPinPad.GetSwipe();
      //...dmb
    except
      on E : Exception do
      begin
        UpdateExceptLog('Reconnecting to Pin Pad ' + e.message);
        ReconnectPinPad('UpdatePinPad1');
      end
      else
      begin
        UpdateExceptLog('Reconnecting to Pin Pad');
        ReconnectPinPad('UpdatePinPad2');
      end;
    end;
  end;
end;

{-----------------------------------------------------------------------------
  Function:  CheckNCRMSR
  Author:    Gary Whetton
  Purpose:
  Arguments: MSROPOSName : string
  Result:    Boolean
  History:
-----------------------------------------------------------------------------}
function TfmPOS.CheckNCRMSR(MSROPOSName : string) : Boolean;
begin
  if Copy(MSROPOSName,1,3) = 'NCR' then
    CheckNCRMSR := true
  else
    CheckNCRMSR := False;
end;

//DSG
{-----------------------------------------------------------------------------
  Procedure: AddGiftFuelDisc
  Author:    Gary Whetton
  Purpose:
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.AddGiftFuelDisc;
begin
  AddSaleList;
  ComputeSaleTotal;
end;

{-----------------------------------------------------------------------------
  Procedure: VoidGiftFuelDisc
  Author:    Gary Whetton
  Purpose:
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.VoidGiftFuelDisc;
begin
  ErrorCorrect;
end;
//DSG

{-----------------------------------------------------------------------------
  Procedure: SendFuelMessageBusy
  Author:    Gary Whetton
  Purpose:
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.SendFuelMessageBusy(var Msg : TMessage);
var
  OutData : pOutFSData;
  TryCount : Byte;
  TerminalNo : byte;
  FuelSrvrMsg : string;
  Orig : string;
  ofl : TList;
  resend : boolean;
  reconnect : boolean;
begin
  TerminalNo := 0;
  ofl := OutFSList.LockList();
  try
    resend := (ofl.Count > 0);
    reconnect := (ofl.Count > 10);
    if resend then
  begin
      OutData := ofl[0];
    Orig := OutData^.Orig;
    TerminalNo := OutData^.TerminalNo;
    FuelSrvrMsg := OutData^.OutMsg;
      ofl.Delete(0);
      dispose(OutData);
    end;
  finally
    OutFSList.UnlockList;
  end;
  if reconnect then
    ReconnectFuel('POS SendFuelMessageBusy',  'Queue length > 10', FuelSrvrMsg, 0); 
  if resend then
  begin
    for TryCount := 1 to 5 do
    begin
      try
        case nFuelInterfaceType of
          1,2 : SendRawFuelMessage(FuelSrvrMsg);
        end;
        break;
      except
        on E: Exception do
          if pos('input-synchronous',e.Message) > 0 then
          begin
            UpdateExceptLog('TfmPOS.SendFuelMessage failed, re-queueing message - %s - %s',[ E.ClassName, E.Message ]);
            New(OutData);
            OutData^.Orig := Orig;
            OutData^.TerminalNo := TerminalNo;
            OutData^.OutMsg := FuelSrvrMsg;
            OutFSList.Add(OutData);
            PostMessage(fmPOS.Handle,WM_OUTFSMSG,0,0);
            exit;
          end
          else
            ReconnectFuel('POS SendFuelMessageBusy', e.message, FuelSrvrMsg, TryCount);
      end;
    end;
  end;

end;

{-----------------------------------------------------------------------------
  Procedure: SendScannedPLU
  Author:    Gary Whetton
  Purpose:   Added to resolve issue with Cyclone scanner when card swiped and Age entry pending
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.SendScannedPLU(var Msg: TMessage);
var
  DataOut : pScannedPLU;
  nNumber : currency;
  sKeyType, sPLU : string;
  eflag : boolean;
begin
  UpdateZLog('SendScannedPLU - enter');
  DataOut := pScannedPLU(Msg.WParam);
  sKeyType := DataOut^.KeyType;
  nNumber := DataOut^.PLU;
  Dispose(DataOut);
  eflag := False;
  try
    sPLU := Format('%.0f', [nNumber]);
  except
    on E: Exception do
    begin
      eflag := True;
      UpdateExceptLog('SendScannedPLU - Error formatting nNumber as a string');
      UpdateZLog('SendScannedPLU - Error formatting nNumber as a string');
      POSError('Scan failed - Call support if persistant');
    end;
  end;
  if not eflag then
    ProcessKey(sKeyType, sPLU,'',False);
end;

{-----------------------------------------------------------------------------
  Procedure: SendScannedKSL
  Author:    Gary Whetton
  Purpose:   Added to resolve issue with Cyclone scanner when card swiped and Age entry pending
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.SendScannedKSL(var Msg: TMessage);
var
  KSLDataOut : pScannedKSL;
begin
  KSLDataOut := pScannedKSL(Msg.WParam);
  sEntry := KSLDataOut^.KSL;
  Dispose(KSLDataOut);
  ProcessKeyKSL;
end;

procedure TfmPOS.ProcessActivation(var Msg: TWMStatus);
{
Handle product activation (such as phone card) responses from the credit server.
Normally, responses from the credit server are for processing card media (and
would be routed to fmNBSCCForm for handling); however, responses for product activation
responses are re-routed to this handler.
}
var
  CCActMsg : string;
  qSalesData : pSalesData;
  j : integer;
begin
  UpdateZLog('inside ProcessActivation function-tarang');
  //ShowMessage('inside ProcessActivation function'); // madhu remove
  CCActMsg := '';
  try
    if (Msg.Status <> nil) then
      begin
        CCActMsg := Msg.Status.Text;
        Dispose(Msg.Status);
      end;
  except
  end;
  if (CCActMsg <> '') then
  begin
    FCardActivationTimeOut := Now() + PRODUCT_ACTIVATION_TIMEOUT_DELTA;
    qSalesData := HandleActivationResponse(CCActMsg);
    if (qSalesData <> nil) then
    begin
      // Response may have adjusted an amount, so re-display
      POSListBox.ItemIndex := qSalesData^.SeqNumber - 1;
      POSListBox.DeleteSelected();                        // remove old line
      POSListBox.ItemIndex := qSalesData^.SeqNumber - 1;
      DisplaySaleList(qSalesData, True);                  // insert new line where old line had been
      PoleMdse(qSalesData, SaleState);
      ComputeSaleTotal();        // Will recalculate nCurAmountDue
      POSListBox.Refresh;
      if (PPTrans <> nil) then
      begin
        for j := max(0, CurSaleList.Count - 1 - PPTrans.ReceiptLines) to CurSaleList.Count - 1 do
          DisplaySaleDataToPinPad(PPTrans, CurSaleList.Items[j]);
      end;
  end;
  end;  // if (CCActMsg <> '')
end;  // procedure ProcessActivation

function TfmPOS.SalesItemQualifiesForAuthReduction(const qSalesData : pSalesData) : boolean;
begin
  Result := (
            (qSalesData^.LineType = 'MED') and (qSalesData^.ExtPrice > 0.0) and
            (not qSalesData^.LineVoided) and (Trim(qSalesData^.SaleType) <> 'Void') and
            (qSalesData^.CCRequestType <> RT_PURCHASE_REVERSE) and
            ((qSalesData^.GiftCardRestrictionCode <> RC_ONLY_FUEL) or (qSalesData^.CCCardType <> CT_GIFT)) and  // cannot return activate amounts to fuel only card
            (Round(qSalesData^.Number) in [CREDIT_MEDIA_NUMBER, DEFAULT_GIFT_CARD_MEDIA_NUMBER, EBT_FS_MEDIA_NUMBER, DEBIT_MEDIA_NUMBER])
                                        );
//UpdateZLog('SIQFAR - %s %.2g %s %s %d %d %s %d POR: %s - %s',
//           [qSalesData^.LineType, qSalesData^.ExtPrice, BoolToStr(qSalesData^.LineVoided, True),
//            Trim(qSalesData^.SaleType), qSalesData^.CCRequestType, qSalesData^.GiftCardRestrictionCode,
//            Trim(qSalesData^.CCCardType), Round(qSalesData^.Number), BoolToStr(qSalesData^.PriceOverridden, True),
//            BoolToStr(Result,True)]);
end;

procedure TfmPOS.BalanceOverTender();
{
Complete the sales tender operation after a response (or timeout) is received on all
products in the sales list that were queued for activation (when the final tender was
first tendered).
}
var
  j : integer;
  bDeactivateToChange : boolean;
  qSalesData : pSalesData;
  AmountToReturn : currency;
  AmountReturned : currency;
  NonApprovedMedia : currency;
  FuelSubTotal : currency;
  OriginalApprovedAmount : currency;
  FinalApprovedAmount : currency;
  j2 : integer;
  AttemptedReductions : integer;
  MediaCreditCount : integer;
  qMinCredit : pSalesData;
  CardReturnAmount : currency;
begin
  UpdateZLog('inside BalanceOverTender function-tarang');
  //ShowMessage('inside BalanceOverTender function'); // madhu remove
  if (SaleState <> ssTender) then
    exit;

  UpdateZLog('BalanceOverTender - Enter');

  //  Re-compute amount due:  (Some products may have failed to activate since final tender started.)
  ReComputeSaleTotal(False);
  // If an activation product failed to activate (and thus was voided from sales list),
  // then amount due would now be negative.  This amount needs to be un-tendered (returns
  // on credit cards and/or change returned).

  AmountToReturn := -curSale.nAmountDue;

  NonApprovedMedia := 0.0;
  FuelSubTotal := 0.0;
  if (AmountToReturn > 0.0) then
  begin
    // Following configuration parameter used to priortize non-approved tenders when
    // deciding canidate tenders (when partial tenders used) for returing non-activated amounts.
    try
      bDeactivateToChange := fmPOS.Config.Bool['CC_DEACT_TO_CHANGE'];
    except
      bDeactivateToChange := False;
    end;
    UpdateZLog('BalanceOverTender - bDeactivateToChange: %s', [BoolToStr(bDeactivateToChange)]);
    for j := 0 to CurSaleList.Count - 1 do
    begin
      qSalesData := CurSaleList.Items[j];
      if (qSalesData^.LineVoided) then
      begin
      end
      else if (bDeactivateToChange and (qSalesData^.LineType = 'MED') and
          (not (Round(qSalesData^.Number) in [CREDIT_MEDIA_NUMBER, DEFAULT_GIFT_CARD_MEDIA_NUMBER, DEBIT_MEDIA_NUMBER]))) then
        NonApprovedMedia := NonApprovedMedia + qSalesData^.ExtPrice
      else if (qSalesData^.LineType = 'FUL') then
        FuelSubTotal := FuelSubTotal + qSalesData^.ExtPrice;
    end;
    AmountToReturn := AmountToReturn - NonApprovedMedia;
  end;

  AmountReturned := 0.0;
  AttemptedReductions := 0;
  if ((AmountToReturn > 0.0) and (CurSaleList.Count > 0)) then
  begin

    // Locate approved media tendered (such as credit card or gift cards) up to the
    // total amount voided from de-activations.

    MediaCreditCount := 0;
    repeat  // until all credit media has been processed
      // Locate qualifying tenders in order last attempted
      qMinCredit := nil;
      for j := CurSaleList.Count - 1 downto 0 do
      begin
        qSalesData := CurSaleList.Items[j];
        if (SalesItemQualifiesForAuthReduction(qSalesData) and (not qSalesData^.PriceOverridden)) then   // not already processed
        begin
          if (AttemptedReductions = 0) then
            Inc(MediaCreditCount);
          if (qMinCredit = nil) then
          begin
            qMinCredit := qSalesData;
          end;
        end;  // if credit media
      end;  // for each item in sales list
      qSalesData := qMinCredit;
      //if attemptedreductions = 0 then updatezlog('BalanceOverTender - MediaCreditCount: %d', [MediaCreditCount]);
      Inc(AttemptedReductions);
      if (qSalesData <> nil) then
      begin
        // Re-authorize to reduced amount
        OriginalApprovedAmount := qSalesData^.ExtPrice;
        //UpdateZLog('BalanceOverTender - ExtPrice: %.2g AmountToReturn: %.2g  AmountReturned: %.2g', [qSalesData^.ExtPrice, AmountToReturn, AmountReturned]);
        CardReturnAmount := Min(qSalesData^.ExtPrice, (AmountToReturn - AmountReturned));
        updatezlog('BalanceOverTender - Reducing Auth %d from %.2g -> %.2g', [qSalesData^.CCAuthId, qSalesData^.ExtPrice, CardReturnAmount]);
        ReduceAuth(curSale.nTransNo, qSalesData, qSalesData^.ExtPrice - CardReturnAmount);  // sets PriceOverridden
        FinalApprovedAmount := qSalesData^.ExtPrice;
        AmountReturned := AmountReturned + OriginalApprovedAmount - FinalApprovedAmount;
        //UpdateZLog('BalanceOverTender - AmountReturned: %.2g', [AmountReturned]);
        // Update displays
        PoleMdse(qSalesData, SaleState);
        ComputeSaleTotal();        // Will recalculate nCurAmountDue
        if (FinalApprovedAmount <> OriginalApprovedAmount) then
        begin
          New(qMinCredit);
          qMinCredit^ := qSalesData^;
          qMinCredit^.ExtPrice := OriginalApprovedAmount;
          qSalesData^.ExtPrice := FinalApprovedAmount;
          DisplayMedia(qSalesData, qMinCredit);
          Dispose(qMinCredit);
        end;
        if (PPTrans <> nil) then
        begin
          for j2 := max(0, CurSaleList.Count - 1 - PPTrans.ReceiptLines) to CurSaleList.Count - 1 do
            DisplaySaleDataToPinPad(PPTrans, CurSaleList.Items[j2]);
        end;
      end;  // if (qMinCredit <> nil)
    until ((AmountReturned >= AmountToReturn) or (AttemptedReductions >= MediaCreditCount));
  end;  // if (AmountToReturn > 0.0)

  // No approved media left to return.
  // Just process any remaining amount credited from voiding activation products as change due.
  AmountToReturn := AmountToReturn + NonApprovedMedia;

  if ((AmountReturned < AmountToReturn) or (curSale.nAmountDue >= 0)) then
  begin
    nAmount := 0;
    sEntry := '0';
    ProcessKeyMed('MED', IntToStr(NULL_MEDIA_NUMBER), '', True);
  end;

  fmPOSMsg.Close;

end;  // procedure BalanceOverTender

procedure TfmPOS.ActivationResponded(var Msg: TWMStatus);
begin
  CompleteActivationResponse();
end;  // procedure ActivationResponded

{-----------------------------------------------------------------------------
  Procedure: ProcessKeyINV
  Author:    Gary Whetton
  Purpose:
  History:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyINV;
begin
  fmInventoryInOut := TfmInventoryInOut.Create(Self);
  fmInventoryInOut.ShowModal;
  fmInventoryInOut.Free;
end;



{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyMOP
  Author:    
  Date:      2008-07-29
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyMOP();
var
  nTemp : integer;
  nOrigQty : currency;
  nRemAmt : currency;
  nCount : integer;
  sMOFplu : string;
  doreturns : boolean;
  voidwindow : integer;
begin
  voidwindow := 0;
  
  if lbReturn.Visible = True then
  begin
    try
      doreturns := Config.Bool['MO_ENABLERETURNS'];
    except
      doreturns := False;
    end;

    if not doreturns then
    begin
      POSError('Cannot return Money Order');
      exit;
    end;

    if nQty > 1 then
    begin
      POSError('Cannot use QTY key with MO Returns');
      exit;
    end;

    fmMOInq := TfmMOInq.Create(Self);
    if fmMOInq.ShowModal = mrOK then
    begin
      Move(fmMOInq.MO,MOInfo,sizeof(MOInfo));
      fmMOInq.Release;
      fmMOInq := nil;
    end
    else
    begin
      fmMOInq.Release;
      fmMOInq := nil;
      exit;
    end;

    try
      voidwindow := Config.Int['MO_VOIDMINUTES'];
    except
      voidwindow := 10;
    end;

    if (voidwindow > 0) and ((Now() - MOInfo.PurchTS) > (voidwindow * OneMinute)) then
    begin
      POSError(MOInfo.SerialNo + ' printed on ' + DateTimeToStr(MOInfo.PurchTS) + ' at ' + IntToStr(MOInfo.Store) + ' for ' + Format('%.2f', [MOInfo.DocValue]) );
      POSError('Call to verify then stamp and drop the form');
      exit;
    end;

    nAmount := MOInfo.DocValue * 100;
    fmMO.SaleList := @CurSaleList;
    if fmMO.DupReturn(MOInfo.SerialNo) then
    begin
      POSError('Cannot return Money Order twice');
      exit;
    end;
  end
  else
  begin

    if sEntry = '' then
    begin
      POSError('Please Enter an Amount!');
      exit;
    end;

    try
      nAmount := StrToFloat(sEntry);
    except
      POSError('Invalid Numeric Entry');
      ClearEntryField;
      Exit;
    end;

    if nAmount = 0 then
    begin
      POSError('Please Enter An Amount');
      Exit;
    end;
  end;

  if not POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.StartTransaction;
  with POSDataMod.IBTempQuery do
  begin
    close;SQL.Clear;
    SQL.Add('Select GrpNo from GRP where Fuel = 6'); //
    open;
    if eof then
    begin
      close;
      if POSDataMod.IBTransaction.InTransaction then
        POSDataMod.IBTransaction.Commit;
      POSError('Money Orders not set up in Group');
      exit;
    end
    else
    begin
      nTemp := fieldbyname('GrpNo').AsInteger;
      close;SQL.Clear;
      SQL.Add('Select * from DEPT where GrpNo = :pGrpNo');
      parambyname('pGrpNo').AsString := inttostr(nTemp);
      open;
      if eof then
      begin
        POSError('Money Orders not set up in Department');
        close;
        if POSDataMod.IBTransaction.InTransaction then
          POSDataMod.IBTransaction.Commit;
        exit;
      end
      else
      begin
        DBInt.GetDept(POSDataMod.IBTempQuery, @Dept);
        close;SQL.Clear;
        SQL.Add('select PLUNO from PLU where name=''Money Order Fee''');
        open;
        if eof then
        begin
          close;
          if POSDataMod.IBTransaction.InTransaction then
            POSDataMod.IBTransaction.Commit;
          POSError('Money Order Fee not set up in PLU');
          exit;
        end
        else
        begin
          sMOFplu := fieldbyname('PLUNO').AsString;
          close;
          if POSDataMod.IBTransaction.InTransaction then
            POSDataMod.IBTransaction.Commit;
        end;
      end;
    end;
  end;

  nAmount := nAmount / 100;
  if (Dept.HALO > 0) and
   (nAmount > Dept.HALO) then
  begin
    POSError('Over High Amount Limit');
    Exit;
  end;

  if (Dept.LALO > 0) and
   (nAmount < Dept.LALO) then
  begin
    POSError('Under Low Amount Limit');
    Exit;
  end;

  if Dept.RestrictionCode > 0 then
    if not RestrictionCodeOK(Dept.RestrictionCode) then
      exit;

  if Dept.MaxCount > 0 then
    if not DepartmentMaxCountOK(Dept.DeptNo, Dept.MaxCount) then
      exit;

  if SaleState = ssNoSale then
    AssignTransNo;

  SaleState := ssSale;
  sLineType := 'DPT';

  if Dept.Subtracting then
    nAmount := nAmount * -1;

  if nQty = 0 then
    nQty := 1;  // assume a qty 1 situation

  if lbReturn.Visible = True then
  begin
    sSaleType := 'Rtrn';
    nQty := nQty * -1;
  end
  else
    sSaleType := 'Sale';

  nOrigQty := nQty;
  nCount := 0;

  nLinkedPLUNo :=  StrToFloat(sMOFplu);
  genSeqLink := True;
  if nAmount > Setup.MOMaxDocValue then
  begin
    nTemp := Floor (nAmount / Setup.MOMaxDocValue);
    nCount := nTemp * floor(nOrigQty);  // ie, need 3 $650 MOs -- floor($650/$300) == 2, nTemp = 2, nQty = 2 * 3
    nQty := nCount;
    nRemAmt := nAmount - (nTemp * Setup.MOMaxDocValue);
    nAmount := Setup.MOMaxDocValue;
    PoleMdse(AddSaleList, SaleState);
    ComputeSaleTotal;
    nAmount := nRemAmt;
    nQty := nOrigQty;
  end;
  if nAmount > 0 then  // remaining amount if > MaxDocValue or amount of single small MO
  begin
    nCount := nCount + Floor(nQty);
    PoleMdse(AddSaleList, SaleState);
    ComputeSaleTotal;
  end;


  if POSDataMod.IBTransaction.InTransaction then
    POSDataMod.IBTransaction.Commit;

  if not lbReturn.Visible then
  begin
    nSeqLink := nSeqLink * -1;
    nQty := nCount;
    ProcessKeyPLU(sMOFplu, '');
  end
  else if (voidwindow > 0) then
  begin
    nSeqLink := nSeqLink * -1;
    nQty := -1;
    ProcessKeyPLU(sMOFplu, '');
  end;

  nSeqLink := 0;
  ClearEntryField;

end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyMOL
  Author:
  Date:      2008-10-06
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyMOL();
begin
  fmMOLoad := TfmMOLoad.Create(Self);
  fmMOLoad.ShowModal;
  fmMOLoad.Release;
  fmMOLoad := nil;
end;

{-----------------------------------------------------------------------------
  Name:      TfmPOS.ProcessKeyMOA
  Author:
  Date:      2008-12-01
  Arguments:
  Result:    None
  Purpose:
-----------------------------------------------------------------------------}
procedure TfmPOS.ProcessKeyMOA();
begin
  fmMOLoad := TfmMOLoad.Create(Self);
  fmMOLoad.loadmode := MOmAssign;
  fmMOLoad.ShowModal;
  fmMOLoad.Release;
  fmMOLoad := nil;
end;

procedure TfmPOS.ProcessKeyMOI();
begin
  fmMOInq := TfmMOInq.Create(Self);
  if fmMOInq.ShowModal = mrOK then
  begin
    Move(fmMOInq.MO,MOInfo,sizeof(MOInfo));
    POSError(MOInfo.SerialNo + ' printed on ' + DateTimeToStr(MOInfo.PurchTS) + ' at ' + IntToStr(MOInfo.Store) + ' for ' + Format('%.2f', [MOInfo.DocValue]) );
  end;
  fmMOInq.Release;
  fmMOInq := nil;
end;

procedure TfmPOS.ProcessKeyMOR();
var
  srange : currency;
begin
  srange := Config.Cur['MO_LASTPRINTED'];
  if not ((srange >= Config.Cur['MO_LOADEDBEGIN']) and (srange <= Config.Cur['MO_LOADEDEND'])) then
    srange := Config.Cur['MO_LOADEDBEGIN'];
  POSError( Format('%d documents remain in the printer',[(trunc(Config.Cur['MO_LOADEDEND'] - srange + 1.0))]) );
end;

function TfmPOS.DepartmentMaxCountOK(DeptNo, MaxCount : integer) : boolean;
var
  TempData : pSalesData;
  ndx : byte;
  ItemCount :double;
  Res : boolean;
begin
  res := true;
  ItemCount := 0;
  if (CurSaleList.Count > 0) and (MaxCount > 0) then
  begin
    for ndx := 0 to CurSaleList.Count - 1 do
    begin
      TempData := CurSaleList[ndx];
      if TempData^.DeptNo = DeptNo then
        ItemCount := ItemCount + TempData^.Qty;
    end;
  end;
  ItemCount := ItemCount + nQty;
  if ItemCount > MaxCount then
  begin
    POSError('Maximum Count Reached');
    Res := false;
  end;
  DepartmentMaxCountOK := Res;
end;
procedure TfmPOS.DisplayEntryKeyPress(Sender: TObject; var Key: Char);
begin
 UpdateZLog('inside DisplayEntryKeyPress function-tarang');
 //ShowMessage('inside DisplayEntryKeyPress function'); // madhu remove
//20061114a  {$IFDEF PLU_MOD_DEPT}
  //20060713g...
  if bSaleComplete then         //GMM:  Inits screen upon new keyed entry
    InitScreen;
  //...20060713g
//20061114a  {$ENDIF}
  if (Key in ['0'..'9']) or (Key = ',') then
  begin
    if length(trim(DisplayEntry.Text)) < 15 then
    begin
      sEntry := sEntry + Key;
      DisplayEntry.Text := format('%15s',[sEntry]);
    end;
  end;
  if Ord(Key) = 13 then
    ProcessKeyPLU(sEntry, '');
end;

procedure TfmPOS.CarwashEventsGotMsg(Sender: TObject;
  const Dest: WideString; TerminalNo: Integer; const MSG: WideString);
var
  MsgDest : string;
  MsgIn : string;
begin
  MsgDest := Dest;
  if (MsgDest = 'POS') and (TerminalNo = ThisTerminalNo) then
  begin
    MsgIn := Msg;
    CWSocketReceiveMessage(Dest, TerminalNo, MsgIn);
  end;
end;

//20070104a...
function TfmPOS.UseCashbackAmountPrompt() : boolean;
begin
  UseCashbackAmountPrompt :=
                       (
                        (((nCashBackType mod 10) = 1) and (PinCreditSelect = PIN_EBT_CB))
                        or
                        (((nCashBackType div 10) = 1) and (PinCreditSelect = PIN_DEBIT))
                        );
end;  // function UseCashbackAmountPrompt

function TfmPOS.UseCashbackOptionPrompt() : boolean;
begin
  UseCashbackOptionPrompt :=
                       (
                        (((nCashBackType mod 10) = 2) and (PinCreditSelect = PIN_EBT_CB))
                        or
                        (((nCashBackType div 10) = 2) and (PinCreditSelect = PIN_DEBIT))
                        );
end;  // function UseCashbackOptionPrompt

function TfmPOS.UseCashbackPrompt() : boolean;
begin
  UseCashbackPrompt :=
                       (
                        (((nCashBackType mod 10) > 0) and (PinCreditSelect = PIN_EBT_CB))
                        or
                        (((nCashBackType div 10) > 0) and (PinCreditSelect = PIN_DEBIT))
                        );
end;  //function UseCashbackPrompt
//...20070104a

//20071107f...Updates Kiosk prices with current Pricebook prices
procedure TfmPOS.UpdateKioskPrices;
type
  pKioskItem = ^TKioskItem;
  TKioskItem = record
    ItemNumber      : Currency;
    ItemPrice       : Currency;
    ItemDisplayPrice: Currency;
    ItemUpdateFlag : Boolean;
  end;

var
 KioskItemList : TList;
 KioskIdx : Integer;
 KioskCnt : Integer;
 KioskItem : pKioskItem;
begin
  KioskCnt := 0;
  KioskItemList := TList.Create;
//  KioskItem := nil;
  try
      with POSDataMod.KioskOrderQry do
      begin
        Close;SQL.Clear;
        ConnectionString := fmPOS.BuildKioskConnectionString;
        SQL.Add('SELECT mi_number, mi_Price, mi_DisplayPrice ');
        SQL.Add('FROM tblMenuItems ');
        SQL.Add('WHERE mi_Class_ID = 1');
        Open;
        KioskCnt := RecordCount;
        If KioskCnt > 0 then
        begin
          while not EOF do
          begin
            fmPOSMsg.ShowMsg('Reading Kiosk items',InttoStr(KioskItemList.Count + 1) + ' of ' + InttoStr(KioskCnt));
            New(KioskItem);
            KioskItem^.ItemNumber := fieldbyname('mi_number').AsCurrency;
            KioskItem^.ItemPrice := fieldbyname('mi_Price').AsCurrency;
            KioskItem^.ItemDisplayPrice := fieldbyname('mi_DisplayPrice').AsCurrency;
            KioskItem^.ItemUpdateFlag := false;
            KioskItemList.Capacity := KioskItemList.Count;
            KioskItemList.Add(KioskItem);
            Next;
          end;
          fmPOSMsg.Hide;
        end;
        Close;
      end
  except
  end;

  if KioskCnt > 0 then
  begin
    For KioskIdx := 0 to KioskItemList.Count - 1 do
    begin
      KioskItem := KioskItemList.Items[KioskIdx];
      fmPOSMsg.ShowMsg('Checking Kiosk items',inttostr(KioskIdx + 1) + ' of ' + InttoStr(KioskItemList.Count));
      if not POSDataMod.IBKioskTrans.InTransaction then
        POSDataMod.IBKioskTrans.StartTransaction;
      with POSDataMod.IBQryKiosk do
      begin
        Close;SQL.Clear;
        SQL.Add('SELECT Price from PLU WHERE PLUNO = :pPLUNo ');
        ParamByName('pPLUNo').AsCurrency := KioskItem^.ItemNumber;
        Open;
        if not eof then
          if fieldbyname('Price').AsCurrency <> KioskItem^.ItemPrice then
          begin
            KioskItem^.ItemPrice := fieldbyname('Price').AsCurrency;
            KioskItem^.ItemDisplayPrice := fieldbyname('Price').AsCurrency;
            KioskItem^.ItemUpdateFlag := True;
            try
              with POSDataMod.KioskOrderQry do
              begin
                Close;SQL.Clear;
                ConnectionString := fmPOS.BuildKioskConnectionString;
                SQL.Add('UPDATE tblMenuItems ');
                SQL.Add('SET mi_Price = ' + CurrtoStr(KioskItem^.ItemPrice) +  ', mi_DisplayPrice = ' + CurrtoStr(KioskItem^.ItemDisplayPrice) + ' ');
                SQL.Add('WHERE mi_Number = ''' + CurrtoStr(KioskItem^.ItemNumber) + ''' AND mi_Class_ID = 1');
                ExecSQL;
                Close;
              end
            except
            end;
          end;
        Close;
      end;
      if POSDataMod.IBKioskTrans.InTransaction then
        POSDataMod.IBKioskTrans.Commit;
    end;
  end;

  if fmPOSMsg.Visible then
    fmPOSMsg.Hide;
  // Clean up list
//  KioskItem := nil;
  For KioskIdx := 0 to KioskItemList.Count - 1 do
  begin
    KioskItem := KioskItemList.Items[KioskIdx];
    try
      Dispose(KioskItem);
    except
    end;
    KioskItemList.Items[KioskIdx] := nil;
  end;
  KioskItemList.Pack;
  KioskItemList.Destroy;

end;  // Procedure UpdateKioskPrices
//...20071107f

procedure TfmPOS.QueryValidCard(const seqno : integer; const Track1, Track2, acctno, expdate, track, encryptedtrackdata, EMVTags : ansistring);
var
  msg : ansistring;
begin
{                                     // madhu g v  27-10-2017   check
<CARDNO>560980XXXXXXXX1021|
<ENTRYMETHOD>2|
<MSGTYPE>VALIDCARD|
<SEQ>733190|
<TRACK2DATA>;476173XXXXXX0119=EXPD?|
<VC_SEQNO>1|
<EMV Track2 Equivalent>T5A:08:h4761739001010119}

   { seqno := 1;
    Track2 := ';476173XXXXXX0119=EXPD?';
    acctno := '560980XXXXXXXX1021';
    expdate := '06/2026';
    EMVTags  := 'T5A:08:h4761739001010119';
    Track := 2;  }
 // ShowMessage('inside QueryValidCard function'); // madhu remove
 UpdateZLog('inside ueryValidCard function-tarang');
  msg := BuildTag(TAG_MSGTYPE, Format('%2.2d', [CC_VALIDCARD])) +
         BuildTag(TAG_VC_SEQNO, Format('%d', [seqno]));
  if track1 <> '' then
    msg := msg + BuildTag(TAG_TRACK1DATA, Track1);
  if track2 <> '' then
    msg := msg + BuildTag(TAG_TRACK2DATA, Track2);
  if track <> '' then
    msg := msg + BuildTag(TAG_ENTRYMETHOD, Track);
  if acctno <> '' then
    msg := msg + BuildTag(TAG_CARDNO, acctno);
  if expdate <> '' then
    msg := msg + BuildTag(TAG_EXPDATE, expdate);
  if EncryptedTrackData <> '' then
    msg := msg + BuildTag(TAG_ENCRYPTEDTRACKDATA, EncryptedTrackData);
  if emvtags <> '' then
    msg := msg + BuildTag(TAG_EMVT2EQUIV, 'ING' + cRS + EMVTags);
  //msg := stringreplace(msg, '|', cFS, [rfReplaceAll]);
  SendCreditMessage(msg);
end;

procedure TfmPOS.PPCardInfoReceived(sender : TObject; const Track1, Track2, CardNo, Track, EncryptedTrackData, EMVTags : widestring);
var
  expdate : widestring;
  seqno : integer;    // madhu gv  27-10-2017   check       start
begin
//CardInfoReceived('TRACK1','TRACK2','CARDNO','TRACK','ENCRYPTEDTRACKDATA',msg);
 UpdateZLog('inside PPCardInfoReceived function and EMVTags-tarang:'+EMVTags);
 // ShowMessage('inside PPCardInfoReceived function and EMVTags:'+EMVTags); // madhu remove
  expdate := '1249';
 { seqno := 1;
    Track2 := ';476173XXXXXX0119=EXPD?';
    CardNo := '560980XXXXXXXX1021';
    expdate := '06/2026';
    EMVTags  := 'T5A:08:h4761739001010119';
    Track := 2; }
  // QueryValidCard(1,'', ';476173XXXXXX0119=EXPD?', '560980XXXXXXXX1021', expdate, '2', encryptedtrackdata, 'T5A:08:h4761739001010119');   madhu g v 27-10-2017   check  end
  QueryValidCard(VC_RET_PPCARDINFORECEIVED, Track1, Track2, CardNo, '', Track, EncryptedTrackData, EMVTags);
  UpdateZLog('After: QueryValidCard function-tarang');
 // ShowMessage('After: QueryValidCard function'); // madhuj remove
end;

procedure TfmPOS.ActivationVCI(const pVCI : pValidCardInfo);
var
  j : integer;
  qSalesData : pSalesData;
begin
  UpdateZLog('Inside: ActivationVCI function-tarang');
  // ShowMessage('Inside: ActivationVCI function');
  ClearActivationProductData(@ActivationProductData);
  if (convertVCIForActivation(pVCI, @ActivationProductData)) then
  begin
    // Verify that the same MSR is not being re-swiped.
    if (ActivationProductData.ActivationCardNo <> '') then
    begin
      for j := 0 to CurSaleList.Count - 1 do
      begin
        qSalesData := CurSaleList.Items[j];
        if (((qSalesData^.LineType = 'PLU') or (qSalesData^.LineType = 'DPT')) and
            (not qSalesData^.LineVoided) and
            ((qSalesData^.SaleType = 'Sale') or (qSalesData^.SaleType = 'Rtrn')) and
            (qSalesData^.CCCardNo = ActivationProductData.ActivationCardNo)) then
        begin
          POSError('Card ...' + RightStr(qSalesData^.CCCardNo, 4) + ' already used:  Use another card.');
          ClearActivationProductData(@ActivationProductData);
          exit;
        end;
      end;
    end;
    if (ActivationProductData.ActivationCardType = CT_GIFT) then
    begin
      ActivationProductData.bNextScanForProduct := True;
      nQty := 1;
      ProcessKeyDPT(IntToStr(Setup.GIFTCARDDEPTNO), '');
      ClearCardActivationPrompt;
    end
    else if (ActivationProductData.ActivationUPC = '') then
    begin
      ActivationProductData.bNextScanForProduct := True;
      IssueCardActivationPrompt('Scan phone card');
    end
    else if (activationProductData.ActivationUPC <> '') and (ActivationProductData.ActivationCardType = CT_PHONE) then
    begin
      UpdateZLog('activating product UPC %s', [ActivationProductData.ActivationUPC]);
      ClearCardActivationPrompt;
      nQty := 1;
      ProcessKey('PLU', ActivationProductData.ActivationUPC, 'CardActivation', False);
    end
    else //if (ActivationProductData.bThisSwipeForProduct) then
    begin
      ActivationProductData.bNextScanForProduct := True;
      nQty := 1;
      ProcessKey('PLU', ActivationProductData.ActivationUPC, '', False);
    end;
  end
end;

procedure TfmPOS.MSRSwipeVCI(const pVCI : pValidCardInfo);
begin
   UpdateZLog('TfmNBSCCForm.ProcessVCI - Sending information to PINPad-tarang');
 // ShowMessage('inside MSRSwipeVCI function'); // madhu remove
  if pVCI.bValid then
  begin
    if fmGiftForm.Visible then
      if (pVCI.CardType = CT_GIFT) or (pVCI.CardType = CT_PHONE) or (pVCI.CardType = CT_STORE_VALUE) or (pVCI.CardType = CT_EBT_FS)then
        fmGiftForm.VCIReceived(pVCI)
      else
        POSError('Card swiped is not a Gift or EBTFS Card')
    else if fmPOSErrorMsg.Visible and (fmPOSErrorMsg.Caption = 'Card Activation') then  // expecting an activated product swipe
    begin
      if pVCI.bActivationType then
        ActivationVCI(pVCI)
      else
        POSError('Card swiped is not an activated product');
    end
    else if pVCI.bActivationType and (pVCI.CardType <> CT_GIFT) then  // not expecting activated product type
      ActivationVCI(pVCI)
    else if (Self.SaleState in [ssSale, ssTender]) then
    begin
      fmNBSCCForm.VCIReceived(pVCI);
      PostMessage(fmPOS.Handle,WM_PREPROCESSKEY, SYNCHRONIZE_PKMED, 0);
    end;
  end
  else
    POSError('Card not valid at this location');
end;

procedure TfmPOS.PPVCIReceived(const pVCI : pValidCardInfo);
{
Pin pad class instance will call this function when customer swipes a card (while device is waiting
for a swipe) to validate the card information (account number and track data).  This procedure will
return output arguments that indicate if card is is an acceptable form of payment and if so, possible
card types (card type determines subsequent prompts issued to customer at pin pad).
}
var
  detail : string;
  ReceiptErrorMsg, detailmsg : pReceiptErrorMsg;
  cpf : TNotList;
begin
  // EBT could have been selected from the pinpad;
  // otherwise, credit server should have determine cardtype when validating card number.
  {
  if (pVCI.bAskDebit and ((fmNBSCCForm.CardType = CT_EBT_FS) or (fmNBSCCForm.CardType = CT_EBT_CB))) then
    pVCI.CardType := fmNBSCCForm.CardType;
  }
  //it server only validates card based on general configuration.
  // Cred If credit server did validate the card, then also verify that current sales list qualifies
  // for a tender of this type.
  // (For example, fuel-only gift cards may be valid cards, but if no fuel were purchased, they would
  // not be for this tender.)

  UpdateZLog('inside PPVCIReceived function-tarang');
  //ShowMessage('inside PPVCIReceived function'); // madhu remove
  detail := '';
  detailmsg := nil;
  if (pVCI.bValid) then
  begin
    if pVCI.bValid and ((not fmPos.bEBTCBAllowed) and (pVCI.CardType = CT_EBT_CB)) then
    begin
      pVCI.CardError := 'EBT Cash Benefits Not supported';
      pVCI.bValid := False;
    end;
    if pVCI.bValid then
    begin
      cpf := CanPayFor(pVCI.mediarestrictioncode, CurSaleList);
      if SalesTotal(cpf) = 0.0 then
        ChangeCCKeyColor(BTN_YELLOW)
      else
        ChangeCCKeyColor(BTN_RED);
      cpf.Free();
    end;
  end;
  UpdateZLog('before : PPTrans.HandleValidCardResp(pVCI.CardNo-tarang');                                                                                                  //21-11-2017    MADHU
  //showmessage('// MADHU CHECK FOR VALID CARD'); // madhu g v
  PPTrans.HandleValidCardResp(pVCI.CardNo, pVCI.CardType, pVCI.bAskDebit, pVCI.bDebitBINMngt, pVCI.bValid);  // MADHU CHECK FOR VALID CARD
   UpdateZLog('after : PPTrans.HandleValidCardResp(pVCI.CardNo-tarang'); 
  if not pVCI.bValid and (not fmPOSErrorMsg.Visible) then
  begin
    New(ReceiptErrorMsg);
    ReceiptErrorMsg.Text := 'Card at PIN Pad not Valid: ' + pVCI.CardError;
    if detail <> '' then
    begin
      New(DetailMsg);
      DetailMsg.Text := detail;
    end;
    PostMessage(fmPOS.Handle, WM_RECEIPTERRORMSG, LongInt(DetailMsg), LongInt(ReceiptErrorMsg));
  end;
  if not pVCI.bValid then
  begin
    ZeroMemory(pVCI, sizeof(TValidCardInfo));
    fmNBSCCform.ClearCardInfo();
  end;
end;  // procedure PPCardInfoReceived

procedure TfmPOS.PPAuthInfoReceived(      Sender        : TObject;
                                    const PinPadAmount  : currency;
                                    const PinPadMSRData : string;
                                    const PINBlock      : string;
                                    const PINSerialNo   : string);
{
Pin pad class instance will call this function when customer at pin pad device and pos system
have provided enough information to request an authorization.
This call only initates an authorization (similar to when the clerk swipes a card).  Pin pad class
method PINPadAuthResponse() will be called once the results of the authorization request return from
the credit server.
}
begin
   UpdateZLog('inside (TfmPOS.PPAuthInfoReceived:-tarang');
  //ShowMessage('inside (TfmPOS.PPAuthInfoReceived: Enter) function'); // madhu remove
  UpdateZLog('TfmPOS.PPAuthInfoReceived: Enter');
  if (fmNBSCCForm.Visible = false) then
  begin
     UpdateZLog('fmNBSCCForm.Visible is not true');
  end;
  if fmNBSCCForm.Visible then
  begin
    if ((PinPadAmount = 0.0) and (PinPadMSRData = '')) then
    begin
      // Customer aborted transaction (such as not verifying amount)
      //if (fmNBSCCForm.CreditAuthToken <> CA_HANDLE_RESPONSE) then
      begin
        fmNBSCCForm.ClearCardInfo;
        fmNBSCCForm.Close();
        POSError('Customer Rejected Amount At PIN Pad');
      end;
    end
    else
      // Pin Pad ready for authorization attempt.            // madhu gv  27-10-2017    check auth
      fmNBSCCForm.PPAuthInfoReceived(Sender, PinPadAmount, PinPadMSRData, PINBlock, PINSerialNo);
      UpdateZLog('After: fmNBSCCForm.PPAuthInfoReceived function-tarang');
      //ShowMessage('After: fmNBSCCForm.PPAuthInfoReceived function'); // madhu remove
  end
  else if fmGiftForm.Visible then
  begin
    if ((PinPadAmount = 0.0) and (PinPadMSRData = '')) then
    begin
      // Customer aborted transaction (such as not verifying amount)
      //if (fmNBSCCForm.CreditAuthToken <> CA_HANDLE_RESPONSE) then
      begin
        fmGiftForm.ClearCardInfo;
        fmGiftForm.Close();
        POSError('Customer Rejected Amount At PIN Pad');
      end;
    end
    else
      // Pin Pad ready for authorization attempt.
      fmGiftForm.PPAuthInfoReceived(Sender, PinPadAmount, PinPadMSRData, PINBlock, PINSerialNo);
  end
  else
    UpdateZLog('TfmPOS.PPAuthInfoReceived: NBSCC or Gift Form not visible');
end;  // procedure PPAuthInfoReceived


procedure TfmPOS.FPCPostTimerTimer(Sender: TObject);
begin
  if POSDataMod.IBDb.TestConnected then
    Self.FFPCPostThread.Resume;
end;

procedure TfmPOS.InjectionPortTriggerAvail(CP: TObject; Count: Word);
begin
  InjectionPort.GetBlock(FInjBlock[FInjLen], Count);
  Inc(FInjLen, Count);
  if Self.InjFrameAvailable then
    Self.InjHandle(Self.InjGetFrame);
end;

function TfmPOS.InjFrameAvailable: boolean;
var
  i, j : integer;
  ifnd, jfnd : boolean;
begin
  ifnd := False; jfnd := False;
  for i := 0 to (FInjLen - 1) do
    if FInjBlock[i] = #02 then
    begin
      ifnd := True;
      break;
    end;
  for j := i to (FInjLen - 1) do
    if FInjBlock[j] = #03 then
    begin
      jfnd := True;
      break;
    end;
  InjFrameAvailable := (ifnd and jfnd);
end;

function TfmPOS.InjGetFrame: string;
var
  i, j : integer;
  ifnd, jfnd : boolean;
begin
  ifnd := False; jfnd := False;
  for i := 0 to (FInjLen - 1) do
    if FInjBlock[i] = #02 then
    begin
      ifnd := True;
      break;
    end;
  for j := i to (FInjLen - 1) do
    if FInjBlock[j] = #03 then
    begin
      jfnd := True;
      break;
    end;
  if ifnd and jfnd then
  begin
    InjGetFrame := copy(FInjBlock, i + 2, j - i - 1 );
    if FInjLen > j then
    begin
      move(FInjBlock[FInjLen], FInjBlock, FInjLen - j);
      FInjLen := FInjLen - j;
    end;
    ifnd := False;
    for i := 0 to (FInjLen - 1) do
      if FInjBlock[i] = #02 then
      begin
        ifnd := True;
        break;
      end;
    if not ifnd then
    begin
      FInjBlock := '';
      FInjLen := 0;
    end;
  end
  else if not ifnd then
  begin
    InjGetFrame := '';
    FInjLen := 0;
  end;
end;

procedure TfmPOS.InjHandle(const cmd : string);
var
  dest : string;
begin
  dest := ParseString(cmd, 1, #30);
  if dest = 'BTN' then
  begin
    ProcessKey(ParseString(cmd, 2, #30),ParseString(cmd, 3, #30), '', False);
    Self.InjLog(Format('InjHandle - done processing BTN - sEntry = "%s"',[sEntry]));
  end
  else if dest = 'BTNRAW' then
  begin
    strpcopy(EntryBuff, #2 + cmd);
    PostMessage(fmPOS.Handle,WM_PREPROCESSKEY,0,0);
  end
  else if dest = 'ERR' then
  begin
    if fmPOSErrormsg.Visible then
    with fmPOSErrormsg do
    begin
      ModalResult := mrOK;
      Close;
    end;
  end;
end;

procedure TfmPOS.InjLog(const msg : string);
begin
  if assigned(Self.InjectionPort) and Self.InjectionPort.Open then
    Self.InjectionPort.PutString(#2 + 'LOG' + #30 + msg + #3);
  if not ((Pos('%',msg)> 0) and ((Pos(';',msg) > 0) or (Pos('^',msg) > 0))) then
    UpdateZLog(msg)
  else
    UpdateZLog(copy(msg, 0, pos('%', msg) - 1) + ' Possible Magstripe');
end;


procedure TfmPOS.PPSigReceived(      Sender  : TObject;
                               const AuthId  : integer;
                               const SigData : string);
var
  Sig : TIngSig;
  sigreplicated, sigaccepted, sigsaved : boolean;
begin
  // Have clerk verify signature:
  // [Program note: replace fmPOSErrorMsg with signature review form.]
  //ShowMessage('inside PPSigReceived function'); // madhu remove
  UpdateZLog('After: inside PPSigReceived function-tarang');
  try
    Sig := TIngSig.Create();
    Sig.PenWidth := 2;
    Sig.SigData3BA := SigData;
    frmSigVerify.SigImg.Picture.Bitmap := Sig.GetBitmap(frmSigVerify.SigImg.Width, frmSigVerify.SigImg.Height);
    Sig.Destroy;
    frmSigVerify.Left := (Self.Width - frmSigVerify.Width) div 2;
    frmSigVerify.Top  := (Self.Height - frmSigVerify.Height) div 2;
    fmNBSCCForm.FormStyle := fsNormal;
    sigreplicated := True;
  except
    on E : Exception do
    begin
      sigreplicated := False;
      UpdateZLog('TfmPOS.PPSigReceived - cannot replicate signature - %s - %s', [E.ClassName, E.Message]);
      UpdateExceptLog('TfmPOS.PPSigReceived - cannot replicate signature - %s - %s', [E.ClassName, E.Message]);
      DumpTraceback(E);
      POSError('Failed to replicate signature');
    end;
  end;
  sigaccepted := sigreplicated and (frmSigVerify.ShowModal() = mrOK);
  sigsaved := False;
  if sigaccepted then
  begin
    UpdateZLog('Signature Accepted : local');
    with POSDataMod.IBTempQuery do
    begin
      try
        if (not Transaction.InTransaction) then
          Transaction.StartTransaction();
        Close();
        SQL.Clear();
        SQL.Add('insert into PinPadSignature (AuthID, SignatureData) values (:pAuthID, :pSignatureData)');
        ParamByName('pAuthID').AsInteger := AuthID;
        ParamByName('pSignatureData').AsString := SigData;
        ExecSql();
        if (Transaction.InTransaction) then
          Transaction.Commit();
        sigsaved := True;
      except
        on E : Exception do
        begin
          if (Transaction.InTransaction) then
            Transaction.Rollback();
          UpdateExceptLog( 'TfmPOS.PPSigReceived - cannot insert AuthID' + IntToStr(AuthID) + ': ' + e.message);
          POSError('Failed to save signature');
       end;
      end;
    end;  // with
  end;
  if (not sigreplicated) or (not sigsaved) or (not sigaccepted) then
    PPTrans.ReIssueSignatureCapture(AuthID, 'Please sign again')
  else
  begin
    // Credit screen would have been closed in NBSCC.pas back when credit response arrived unless
    // a signature was to be captured (now OK to close credit screen).
    //This is also where we are going to call the FinalizeSale as all processes should now be complete :local
    //UpdateZLog('Finalize Sale :local');
    //Self.FinalizeSale();
    if (fmNBSCCForm.Visible) then
    begin
      fmNBSCCForm.Close();  // Will cause processing of media to resume
    end;
  end;
  fmNBSCCForm.FormStyle := fsStayOnTop;
  UpdateZLog('Exit: inside PPSigReceived function-tarang');
  //PPTrans.SendAdRequest(1);
end;

function TfmPOS.PPPromptChange(      Sender         : TObject;
                               const PinPadStatusID : string;
                               const PinPadPrompt   : string) : boolean;
{
Update the credit screen so clerk will have an idea about the prompting at the pin pad.
}
begin
  //ShowMessage('inside PPPromptChange function'); // madhu remove
    UpdateZLog('inside PPPromptChange function-tarang');
//  if (fmNBSCCForm.CreditAuthToken <> CA_HANDLE_RESPONSE) then  // do no overwrite credit server status
//    fmNBSCCForm.lPinPadStatus.Caption := ' Pin Pad: ' + Copy(PinPadPrompt, 1, 30);
  Result := True;
  if (FSaleState <> ssNoSale) then
  begin
      UpdateZLog('fmNBSCCForm.PPPromptChange(sender, pinpadstatusid, pinpadprompt)-tarang');
    //ShowMessage('fmNBSCCForm.PPPromptChange(sender, pinpadstatusid, pinpadprompt)'); // madhu remove
    //if (fmNBSCCForm.CreditAuthToken <> CA_HANDLE_RESPONSE) then  // do no overwrite credit server status
      fmNBSCCForm.PPPromptChange(sender, pinpadstatusid, pinpadprompt);

    //else
    //  Result := False
    end
  else
    if ((Copy(PinPadPrompt, 1, 30) <> 'Advertising') and (not TPinPadTrans(Sender).bBalanceInquiry)) then
    begin
      TPinPadTrans(Sender).TransNo := 0;
      TPinPadTrans(Sender).nCount := 1;       // Michael added this to see if this kicks off the EMV stuff
      updateZlog('Pinpad in "' + Copy(PinPadPrompt, 1, 30) + '" instead of Advertising - reset');
    end;

end;

procedure TfmPOS.FormCreate(Sender: TObject);
var
  ndx : integer;
begin
  FCurSaleList := TNotList.Create;
  FCurSaleList.Name := 'CurSaleList';
  FCurSaleList.Clear;

  FCurSalesTaxList := TNotList.Create;
  FCurSalesTaxList.Name := 'CurSalesTaxList';
  FCurSalesTaxList.Clear;
  // Critical section to serialize calculation and posting of tax list.
  InitializeCriticalSection(CSTaxList);

  FSavSalesTaxList := TList.Create;
  FSavSalesTaxList.Clear;

  FPostSalesTaxList := TList.Create;
  FPostSalesTaxList.Clear;

  FPostSaleList := TNotList.Create;
  FPostSaleList.Name := 'PostSaleList';
  FRestrictedDeptList := TList.Create;
  FPopUpMsgList := TList.Create;
  FoutFSList := TThreadList.Create;

  InitTaxTables();

  try
    for ndx := 0 to NUM_CREDIT_CLIENTS - 1 do
      CreditClient[ndx].RestrictSalesTaxList := TList.Create;
  except
    UpdateExceptLog('Credit Client array (Restriction) initialization error');
  end;

  PPStatus := TPPStatus.Create(Self);
  PPStatus.Parent := Self;
  PPStatus.Top := eTotal.Top;
  PPStatus.Left := POSListBox.Left;
  PPStatus.Visible := False;

  MCPStatus := TIndicator.Create(self);
  MCPStatus.Parent := StatusBar1;
  MCPStatus.Visible := True;

  CreditStatus := TIndicator.Create(self);
  CreditStatus.Parent := StatusBar1;
  CreditStatus.Visible := True;

  FuelStatus := TIndicator.Create(self);
  FuelStatus.Parent := StatusBar1;
  FuelStatus.Visible := True;

  MOStatus := TIndicator.Create(self);
  MOStatus.Parent := StatusBar1;
  MOStatus.Visible := True;
end;

procedure TfmPOS.UpdateIndicatorLocations(sb : TStatusBar);
var
  ndx : integer;
  w : integer;
begin
  w := 0;
  for ndx := 0 to 4 do
    w := w + sb.Panels.Items[ndx].Width;
  MCPStatus.Top := 6;
  MCPStatus.Left := w + 8 + (5 + 32) * 0;
  CreditStatus.Top := 6;
  CreditStatus.Left := w + 8 + (5 + 32) * 1;
  FuelStatus.Top := 6;
  FuelStatus.Left := w + 8 + (5 + 32) * 2;
  MOStatus.Top := 6;
  MOStatus.Left := w + 8 + (5 + 32) * 3;
end;

procedure TfmPOS.FormDestroy(Sender: TObject);
var
  ndx : integer;
  tmplist : TList;
begin
  if assigned(FPostSaleList) then
  begin
    DisposeSalesListItems(FPostSaleList);
    FPostSaleList.Free;
  end;

  if assigned(FCurSaleList) then
  begin
    DisposeSalesListItems(FCurSaleList);
    FCurSaleList.Free;
  end;

  if assigned(FCurSalesTaxList) then
  begin
    DisposeTListItems(FCurSalesTaxList);
    FCurSalesTaxList.Free;
  end;
  DeleteCriticalSection(CSTaxList);

  if assigned(FSavSalesTaxList) then
  begin
    DisposeTListItems(FSavSalesTaxList);
    FSavSalesTaxList.Free;
  end;

  if assigned(FPostSalesTaxList) then
  begin
    DisposeTListItems(FPostSalesTaxList);
    FPostSalesTaxList.Free;
  end;

  if assigned(FRestrictedDeptList) then
  begin
    DisposeTListItems(FRestrictedDeptList);
    FRestrictedDeptList.Free;
  end;

  if assigned(FPopUpMsgList) then
  begin
    DisposeTListItems(FPopUpMsgList);
    FPopUpMsgList.Free;
  end;

  ReleaseTaxTables();

  if assigned(FoutFSList) then
  begin
    tmplist := FoutFSList.LockList;
    try
      DisposeTListItems(tmplist);
      tmplist.Clear;
    finally
      FoutFSList.UnlockList;
    end;
    FoutFSList.Free;
  end;

  for ndx := 0 to NUM_CREDIT_CLIENTS - 1 do
    if assigned(CreditClient[ndx].RestrictSalesTaxList) then
    begin
      DisposeTListItems(CreditClient[ndx].RestrictSalesTaxList);
      CreditClient[ndx].RestrictSalesTaxList.Destroy;
    end;

  FreeAndNil(FPinPadOnlineEvent);

end;

procedure TfmPOS.PPOnlineChange(Sender : TObject);
var
  i : integer;
begin
   UpdateZLog('inside PPOnlineChange function-tarang');
  //ShowMessage('inside PPOnlineChange function'); // madhu remove
  if Sender is TPINPadTrans then
    with TPINPadTrans(Sender) do
    begin
      if PPStatus <> nil then
        PPStatus.Online := PinPadOnline;

      if PinPadOnline and (Self.SaleState <> ssNoSale) then
      begin
        TransNo := curSale.nTransNo;
        if (CurSaleList.Count > 0)  then
          for i := max(0, CurSaleList.Count - 1 - PPTrans.ReceiptLines) to CurSaleList.Count - 1 do
            DisplaySaleDataToPinPad(TPINPadTrans(Sender), CurSaleList.Items[i]);
      end;  // PinPadOnline and !NoSale
    end // with
  else
    UpdateExceptLog('TfmPOS.PPOnlineChange called by unexpected sender - %s', [Sender.ClassName]);
end;

procedure TfmPOS.PPCustomerDataReceived(Sender : TObject; const exittype : TPPEntryExitType; const entrytype : TPPEntry; const entry : string);
begin
  case entrytype of
    //TPPEntry = (ppeNone, ppePhoneNo = 250, ppeVehicleNo = 237, ppeDriverID = 236, ppeID = 242, ppeOdometer = 239, ppeZipCode=249);
    ppePhoneNo : self.PPPhoneNumberReceived(Sender, exittype, entry);
    ppeVehicleNo, ppeDriverID, ppeID, ppeOdometer, ppeZipCode : fmNBSCCForm.PPCustomerDataReceived(Sender, exittype, entrytype, entry);
  end;
end;

procedure TfmPOS.PPSerialNoChanged(const msg : string);
begin
  SendCreditMessage(BuildTag(TAG_MSGTYPE, IntToStr(CC_HWREPORTSERIAL)) +
                    BuildTag(TAG_DEVICE, 'PinPad') +
                    BuildTag(TAG_SERIALNO, msg));
end;

procedure TfmPOS.PPPhoneNumberReceived(Sender : TObject; const exittype : TPPEntryExitType; const entry : string);
begin
  if fmPPEntryPrompt.Visible then
    if (exittype = ppeetEnter) then
    begin
      fmPPEntryPrompt.response := entry;
      fmPPEntryPrompt.ModalResult := mrOK;
    end
    else
      fmPPEntryPrompt.ModalResult := mrCancel;
end;


procedure TfmPOS.PPLoggingClick(Sender: TObject);
begin
  bPPLogging := not bPPLogging;
  try
    POSRegEntry := TRegIniFile.Create('Latitude');
    POSRegEntry.WriteBool('LatitudeConfig', 'PPLogging', bPPLogging);
    POSRegEntry.Free;
  except
  end;
  UpdatePPLoggingDisplay;
  PPTrans.LoggingEnabled := bPPLogging;

end;

procedure TfmPOS.UpdatePPLoggingDisplay();
begin
  if bPPLogging then
    PPLogging.Caption := 'PinPad Logging is On'
  else
    PPLogging.Caption := 'PinPad Logging is Off';
end;


procedure TfmPOS.DisplaySaleDataToPinPad(PP : TPinPadTrans ; SD : pSalesData);
begin
  if PP <> nil then
  begin
    if ((not SD^.LineVoided) and
        ((SD^.SaleType = 'Sale') or (SD^.SaleType = 'Rtrn') or (SD^.SaleType = 'Void'))) then
      PP.PINPadNewSaleItem( SD^.SeqNumber, SD^.ExtPrice, SD^.Qty, SD^.Name, curSale.nTlTax, curSale.nAmountDue)
    else if (SD^.LineType = 'MED') then
      PP.PINPadNewSaleItem( SD^.SeqNumber, -SD^.ExtPrice, 1.0, SD^.Name, curSale.nTlTax, curSale.nAmountDue);
  end;
end;

procedure TfmPOS.SendCancelOnDemand(PP : TPinPadTrans);
begin
  if PP <> nil then
      PP.SendCancelOnDemand();
end;

procedure TfmPOS.SendCardRead(PP : TPinPadTrans);
begin
  if PP <> nil then
      PP.SendReadCard();
end;

procedure TfmPOS.SendSetTransactionType(PP : TPinPadTrans);
begin
  if PP <> nil then
      PP.SendSetTransactionType();
end;

procedure TfmPOS.SendSetAmount(PP : TPinPadTrans);
begin
  // this will need to call sendinitialsetamount with the total amount
  if PP <> nil  then
  begin
      PP.SendInitialSetAmount(curSale.nAmountDue);
  end;
end;

procedure TfmPos.AbortPinPadOperation();
{
Abort any pending operation on the pin pad and re-display the sales list on the pin pad.
}
var
  j : integer;
  transno : integer;
begin
  if (Self.PPTrans <> nil) then
  begin
    transno := PPTrans.TransNo;
    PPTrans.PINPadCancelAction();
    PPTrans.TransNo := transno;
    for j := max(0, CurSaleList.Count - 1 - PPTrans.ReceiptLines) to CurSaleList.Count - 1 do
      DisplaySaleDataToPinPad(PPTrans, CurSaleList.Items[j]);
  end;
end;

procedure TfmPOS.ChangeCCKeyColor(const ColorIdx : byte);
begin
  if nCCKey <> 0 then
    POSButtons[nCCKey].Frame := BTN_SQR + ColorIdx;
end;

procedure TfmPOS.UpdateCCKeyColor();
begin
  if PPTrans <> nil then
  begin
    if not PPTrans.SwipePending then
      ChangeCCKeyColor(BTN_GREEN)
    else
      ChangeCCKeyColor(BTN_RED);
  end
  else
    ChangeCCKeyColor(BTN_GREEN);

end;

procedure TfmPOS.OnPinPadSwipeChange(Sender : TObject);
begin
  //ShowMessage('inside (OnPinPadSwipeChange - SwipePending) function'); // madhu remove
  UpdateZLog('OnPinPadSwipeChange - SwipePending = ' + BoolToStr(TPinPadTrans(Sender).SwipePending, True));
  Self.UpdateCCKeyColor();
end;


procedure TfmPOS.menuShowCursorClick(Sender: TObject);
begin
  if Pos('Show',menuShowCursor.Caption) > 0 then
  begin
    ShowCursor(True);
    menuShowCursor.Caption := 'Hide Cursor';
  end
  else
  begin
    ShowCursor(False);
    menuShowCursor.Caption := 'Show Cursor';
  end;
end;

{
procedure TfmPOS.OnIBEjectRequest(Sender : TObject);
begin
  UpdateZLog('TfmPOS.OnIBEjectRequest - Closing Tables');
  CloseTables;
  if Assigned(Self.PPTrans) then
    Self.PPTrans.PINPadClose;
end;
}


procedure TfmPOS.PumpMenuItemClick(Sender: TObject);
var
  Menu : TPopupMenu;
  MenuItem : TMenuItem;
begin
  MenuItem := TMenuItem(Sender);
  UpdateExceptLog('PumpMenuItemClick: MenuItem - %s, %d', [MenuItem.Caption, MenuItem.Tag]);
  Menu := TPopupMenu(MenuItem.GetParentMenu);
  UpdateExceptLog('PumpMenuItemClick: Menu - %s, %d', [Menu.Name, Menu.Tag]);
  if assigned(Self.PumpLockMgr) and (MenuItem.Tag <> 0) and (Menu.Tag <> 0) then
    case MenuItem.Tag of
      1 : Self.PumpLockMgr.UnlockPump(TPumpxIcon(Menu.Tag).PumpNo);
      2 : Self.PumpLockMgr.PowerPump(TPumpxIcon(Menu.Tag).PumpNo);
      3 : Self.PumpLockMgr.DepowerPump(TPumpxIcon(Menu.Tag).PumpNo);
    end;
  Menu.Tag := 0;
end;

function TfmPOS.IsActivationQueued() : boolean;
var
  bActivationQueued : boolean;
  qSalesData : pSalesData;
  ndx : integer;
begin
  bActivationQueued :=  False;  // Initial assumption
  for ndx := 0 to CurSaleList.Count - 1 do
  begin
    qSalesData := CurSaleList.Items[ndx];
    if ((qSalesData^.ActivationState = asActivationNeeded) and (not qSalesData^.LineVoided)) then
    begin
      UpdateZLog('IsActivationQueued - True');
      bActivationQueued :=  True;
      break;
    end;
  end;
  IsActivationQueued := bActivationQueued;
end;

procedure TfmPOS.ReduceAuth(const transno : integer; const qSalesData : pSalesData; const FinalAuthAmount : currency);
{
Reduce the credit media sales line (in qSalesData) to the indicated final authorization amount.
}
var
  pVCI : pValidCardInfo;
begin

  //ShowMessage('inside ReduceAuth function  and Before finalize auth - ExtPrice'); // madhu remove
  UpdateZLog('Before finalize auth - ExtPrice = ' + FormatFloat('###,###.00 ;###,###.00-', qSalesData^.ExtPrice));
  New(pVCI);
  ExtractVCIFromSalesList(qSalesData, pVCI);
  pVCI^.FinalAmount := FinalAuthAmount;
  fmNBSCCform.ClearCardInfo();
  UpdateZLog('Inside : ReduceAuth function and fmNBSCCForm.VCIReceived(pVCI);-tarang');
//  ShowMessage('Inside : ReduceAuth function and fmNBSCCForm.VCIReceived(pVCI);'); // madhu remove
  fmNBSCCForm.VCIReceived(pVCI);          // MADHU GV CHECK   FOR emv AUTH
  Dispose(pVCI);
  fmNBSCCForm.CurrentTransNo := TransNo;
  fmNBSCCForm.ChargeAmount := FinalAuthAmount;
  fmNBSCCForm.InitialScreen();
  fmNBSCCForm.Authorized := 0;  // madhu g v  23-10-2017
  fmNBSCCForm.ShowModal;    // reduce auth
  qSalesData^.PriceOverridden := True;  // No need to finalize once sale is posted.
  UpdateZLog('After finalize auth - fmNBSCCForm.Authorized = %d', [fmNBSCCForm.Authorized]);

  if (fmNBSCCForm.Authorized <> 0) then
  begin
    // Re-load information provided by final reduced authorization.
    if (FinalAuthAmount = 0.0) then
      qSalesData^.Price          := FinalAuthAmount
    else
      qSalesData^.Price          := fmNBSCCForm.ChargeAmount;
    qSalesData^.Qty            := 1.0;
    qSalesData^.ExtPrice       := qSalesData^.Qty * qSalesData^.Price;
    UpdateZLog('After finalize auth - ExtPrice = ' + FormatFloat('###,###.00 ;###,###.00-', qSalesData^.ExtPrice));
    moveCRDintoSaleData(@rCRD, qSalesData);
  end;
  UpdateZLog('End : ReduceAuth function;-tarang');
  //ShowMessage('End : ReduceAuth function '); // madhu remove
end;

procedure TfmPOS.SetPolePort(const poleport : TApdComPort);
begin
  POSPole.poleport := poleport;
end;

function TfmPOS.GetPolePort : TApdComPort;
begin
  GetPolePort := POSPole.PolePort;
end;

procedure TfmPOS.QueryLoggedOnInfo(const SeqNo : integer; UserID :  integer);
var
  SysMsg : string;
begin
  SysMsg := BuildTag(MCP_MSGTYPE, IntToStr(MCP_LOGGED_ON_INFO))
          + BuildTag(MCP_LU_SEQNO, IntToStr(SeqNo))
          + BuildTag(MCP_TERMINALNO, IntToStr(ThisTerminalNo))
          + BuildTag(MCP_USERID, InttoStr(UserID));
  sendMCPMessage(sysmsg);
end;

procedure TfmPOS.SendUserID(const Msg : string);
var
  UserID : integer;
  SeqID : string;
  RespMsg : string;
begin
  // Notify logon server who is logged onto this register.
  try
    if DAYCLOSEInProgress then
      UserID := 999999
    else if (CurrentUserID = 'XXXX') then
        UserID := SUPPORT_USER_ID
    else if (CurrentUserID <> '') then
        UserID := strtoint(CurrentUserID)
    else
      UserID := 0;
  except
    UserID := 0;
  end;
  {$IFDEF DEV_TEST}
  if (GetTagData(FSTAG_TERMINALNO, Msg) = '2') then
  begin
    RespMsg := BuildTag(MCP_MSGTYPE, IntToStr(MCP_GET_USERID_RET))
             + BuildTag(MCP_TERMINALNO, '2')
             + BuildTag(MCP_USERID, InttoStr(1111));
    SeqID := GetTagData(MCP_MSGSEQ, Msg);
    if SeqID <> '' then
      RespMsg := RespMsg + BuildTag(MCP_MSGSEQ, SeqID);
    sendMCPMessage(respmsg);
  end
  else
  {$ENDIF}
  begin
    RespMsg := BuildTag(MCP_MSGTYPE, IntToStr(MCP_GET_USERID_RET))
             + BuildTag(MCP_TERMINALNO, IntToStr(ThisTerminalNo))
             + BuildTag(MCP_USERID, InttoStr(UserID));
    SeqID := GetTagData(MCP_MSGSEQ, Msg);
    if SeqID <> '' then
      RespMsg := RespMsg + BuildTag(MCP_MSGSEQ, SeqID);
    sendMCPMessage(respmsg);
  end;
end;

procedure TfmPOS.menuFuelMsgLoggingClick(Sender: TObject);
begin
  bFuelMsgLogging := not bFuelMsgLogging;
  try
    POSRegEntry := TRegIniFile.Create('Latitude');
    POSRegEntry.WriteBool('LatitudeConfig', 'FuelMsgLogging', bFuelMsgLogging);
    POSRegEntry.Free;
  except
  end;
  UpdateFuelLoggingDisplay;
end;

procedure TfmPOS.UpdateFuelLoggingDisplay();
begin
  if bFuelMsgLogging then
    menuFuelMsgLogging.Caption := 'Fuel Msg Logging On'
  else
    menuFuelMsgLogging.Caption := 'Fuel Msg Logging Off';
end;

procedure TfmPOS.DisposeSalesListItems(l : TNotList);
var
  sd : pSalesData;
  i : integer;
begin
  if l.Count > 0 then
    for i := 0 to pred( l.Count ) do
    begin
      sd := pSalesData( l.Items[i] );
      if assigned( sd^.paidlist ) then
      begin
        DisposeTListItems( sd^.paidlist );
        try
          sd^.paidlist.Free;
        except
        end;
        sd^.paidlist := nil;
      end;
      if l.Items[i] <> nil then
        dispose( l.Items[i] );
      l.Items[i] := nil;
    end;
end;

procedure TfmPOS.SyncLogging1Click(Sender: TObject);
begin
  SyncLogs := not SyncLogs;
  try
    POSRegEntry := TRegIniFile.Create('Latitude');
    POSRegEntry.WriteBool('LatitudeConfig', 'SyncLogging', SyncLogs);
    POSRegEntry.Free;
  except
  end;
  UpdateLoggingDisplay;
  UpdateZLog('');
end;



procedure TfmPOS.Button1Click(Sender: TObject);
Var
   xVar : String;
begin
   xVar := '1,071101001555,1,071101017402,1,071101019208,1,71101024806,1,071101020808';
   ProcessTdBarCode(xVar);
end;

end.

