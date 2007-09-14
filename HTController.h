/*
   This file is part of HexToaster, an OS X Numeric Base Converter

   Copyright (C) 2004 Jason Kingan
      jasonk@toast442.org

	http://www.toast442.org/hextoaster

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
   02111-1307, USA.

   The GNU General Public License is contained in the file COPYING.
*/

/* HTController */

#import <Cocoa/Cocoa.h>

#define HT_CALCULATOR_FIELD 6

#define HT_ADVANCED 0
#define HT_BASIC 1

#define HT_BASIC_Y 247
#define HT_ADVANCED_Y 363

#define HT_ASCII 1

#define HT_CALC_AND 0
#define HT_CALC_OR  1
#define HT_CALC_XOR 2

@interface HTController : NSObject
{
 	NSMutableArray * fieldArray;
	NSMutableArray * menuArray;
	NSMutableArray * formatterArray;

	NSUserDefaults * prefs;
	
	IBOutlet id baseField1;
    IBOutlet id baseField2;
    IBOutlet id baseField3;
    IBOutlet id baseField4;
    IBOutlet id baseField5;

    IBOutlet id baseField6;
    IBOutlet id baseField7;
    IBOutlet id baseField8;

    IBOutlet id baseMenu1;
    IBOutlet id baseMenu2;
    IBOutlet id baseMenu3;
    IBOutlet id baseMenu4;
    IBOutlet id baseMenu5;

    IBOutlet id baseMenu6;
    IBOutlet id baseMenu7;
    IBOutlet id baseMenu8;
	
	IBOutlet id functionMatrix;
	IBOutlet id modeButton;
	
	int uiMode;
	int calcMode;
}
- (NSString *)convertToBase:(int)newBase fromBase:(int)oldBase  usingText:(NSString *)text;
- (IBAction)baseChanged:(id)sender;
- (IBAction)setMode:(id)sender;
- (IBAction)setMode:(int) mode with: (id)sender;
- (id) init;
- (void)updateCalculator;
- (void)awakeFromNib;
- (void)dealloc;
- (void)controlTextDidChange:(NSNotification *)aNotification;
- (void)windowWillClose:(NSNotification *)aNotification;
- (void)windowDidBecomeMain:(NSNotification *)aNotification;

@end
