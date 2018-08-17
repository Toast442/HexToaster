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

#import "HTController.h"
#import "HTFormatter.h"
#include <gmp.h>

#define HT_HEX(_x) (( _x >= '0' && _x <= '9' ) ? _x-'0' : (( _x >= 'a' && _x <= 'f') ? _x-'a'+10 : -1))

NSString * labels[] = { 0, @"ASCII", @"Binary", 0, 0, 0, 0, 0, @"Octal",
						0,@"Decimal", 0,0,0,0,0, @"Hex", 0,0,0,0,0,0,0,0,0,0,0,0,0,0,
						0,0,0,0,0,0,0 };


@implementation HTController

- (id)init
{
	[ super init ];

	NSMutableDictionary * p = [ NSMutableDictionary dictionary ];
	
	[ p setObject:@"Decimal" forKey:@"baseMenu1" ];
	[ p setObject:@"Hex" forKey:@"baseMenu2" ];
	[ p setObject:@"Octal" forKey:@"baseMenu3" ];
	[ p setObject:@"Binary" forKey:@"baseMenu4" ];
	[ p setObject:@"ASCII" forKey:@"baseMenu5" ];
	[ p setObject:@"Binary" forKey:@"baseMenu6" ];
	[ p setObject:@"Binary" forKey:@"baseMenu7" ];
	[ p setObject:@"Binary" forKey:@"baseMenu8" ];
	[ p setValue: [ NSNumber numberWithInt: HT_BASIC ] forKey:@"UIMode" ];
	[ p setValue: [ NSNumber numberWithInt: HT_CALC_AND ] forKey:@"calcMode" ];
	
	prefs = [[ NSUserDefaults standardUserDefaults] retain ];

	[ prefs registerDefaults: p ];

	uiMode = -1;
	calcMode = HT_CALC_AND;
	
	return self;
}	

- (NSString *)convertToBase:(int)newBase fromBase:(int)oldBase 
	usingText:(NSString *)text
{
	char * buf;
	NSString * str;
	
	mpz_t num;
	mpz_init(num);
	
	// Handle Special Case ASCII input. This converts the ASCII string into HEX and then
	// processes it as if it were base 16 input.
	if(oldBase == HT_ASCII) {
		int i;
		int count;
		const char * buf;
		NSString * s;
		NSAutoreleasePool * p;
		
		s = [[ NSString alloc ] init ];

		// We'll allocate our own autorelease pool here to handle the massive object creating
		// that can happen in the loop. No sense waiting until program exit for memory deallocation.
		p = [[ NSAutoreleasePool alloc ] init];

		buf = [ text UTF8String ];
		count = strlen(buf);
	
		for(i=0; i< count; i++) {
			s = [ s stringByAppendingFormat:@"%02x", buf[i] ];
		}
	
		[ s retain ];
		// Release the pool. We've retained s so it will stick around a little longer.
		[ p release ];
		// Ok, set text
		text = [ NSString stringWithString: s ];
		// Now release s - we're done with it.
		[ s release ];
		oldBase = 16;
	}

	mpz_set_str(num,[ text UTF8String ],oldBase);
	buf = mpz_get_str(NULL, newBase == HT_ASCII ? 16 : newBase, num);

	if(newBase == HT_ASCII) {
		const char * b;
		unichar bb;
		int count;
		int value;

		count = strlen(buf);
		b = buf;
		value = 0;
		
		str = [[[ NSString alloc] init ] autorelease];
		
		while(*b) {
			value = 0;
			if(strlen(b) > 1) {
				value += (HT_HEX(*b) * 16);
				value += (HT_HEX(*(b+1)));
				b+=2;
			} else {
				value += (HT_HEX(*b));
				b++;
			}
			
			bb = (unichar) ( value & 0x80 ) ? '?' : value;

			str = [ str stringByAppendingString: [ NSString stringWithCharacters:(const unichar*)&bb length: 1 ]];
		}
	} else {
		str = [NSString stringWithUTF8String: buf ];
	}
	
	free(buf);

    return str;
}

// Called when one of the pop-up buttons is changed. We need to update the appropriate text field
// to display the contents with a new base.
- (IBAction)baseChanged:(id)sender
{
	int index;
	int newBase;
	int oldBase;
	
	HTFormatter * formatter;
	NSTextField * field;

	index = [ menuArray indexOfObject: sender ];

	if(index == NSNotFound)
		return;
	
	formatter = [ formatterArray objectAtIndex: index ];
	field     = [ fieldArray objectAtIndex: index ];
	
	oldBase = [ formatter getBase ];
										
	[ formatter setBase: [ sender indexOfSelectedItem ] + 1];

	newBase = [ formatter getBase ];
	
	[ field setStringValue: [ self convertToBase: newBase fromBase: oldBase 
			usingText: [ field stringValue ]]]; 

	[ prefs setObject: [ sender titleOfSelectedItem ] forKey: [ NSString stringWithFormat:@"baseMenu%d",index+1 ]];

}

// Called when one of the text fields has had a successful change of contents.
// Basically whenever a key is kit.
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	NSTextField * field;
	
	int index;
	int count;
	int i;
	int base;
	int newBase;
	
	NSString * str;
	
	count = [ fieldArray count ];
	
	field = [ aNotification object ];
	str = [ field stringValue ];
	
	index = [ fieldArray indexOfObject: field ];
	base = [[ formatterArray objectAtIndex: index ] getBase ];
	
	// Loop through the fields, and update them with the new value taken from the 
	// control that was just modified.
	for(i=0; i < HT_CALCULATOR_FIELD && field != baseField7; i++) {
		// Skip over originating control
		if(i == index)
			continue;
		
		newBase = [[ formatterArray objectAtIndex: i ] getBase ];
		
		[[ fieldArray objectAtIndex: i ] setStringValue: 
			[ self convertToBase:newBase fromBase: base usingText: str ]];
	}

	[ self updateCalculator ];
}

- (void)updateCalculator
{
	mpz_t op1;
	mpz_t op2;
	mpz_t result;

	NSString * str;
	char * buf;
	
	mpz_init(op1);
	mpz_init(op2);
	mpz_init(result);
	
	mpz_set_str(op1,[[ baseField6 stringValue ] UTF8String ],
		[[ formatterArray objectAtIndex: 5 ] getBase ] );
		
	mpz_set_str(op2,[[ baseField7 stringValue ] UTF8String ],
		[[ formatterArray objectAtIndex: 6 ] getBase ] );

	calcMode = [ functionMatrix selectedColumn ];

	switch(calcMode) {
		default:
		case HT_CALC_AND:
			mpz_and(result,op1,op2);
			break;
		case HT_CALC_OR:
			mpz_ior(result,op1,op2);
			break;
		case HT_CALC_XOR:
			mpz_xor(result,op1,op2);
			break;
	}

	buf = mpz_get_str(NULL, 10, result);
	str = [ NSString stringWithUTF8String: buf ];
	free(buf); 
	
	[ baseField8 setStringValue: [ self convertToBase: [[ formatterArray objectAtIndex: 7 ] getBase ]
		fromBase:10 usingText: str ]];
	
}

- (void)setCalc:(id) sender
{
		calcMode = [ functionMatrix selectedColumn ];	
		[ prefs setInteger: calcMode forKey:@"calcMode" ];
		[ self updateCalculator ];
}

- (void)awakeFromNib
{
	int count;
	int i;
	int base;

	NSTextField * field;
	NSPopUpButton * menu;
	HTFormatter * formatter;
	
	fieldArray = [[ NSMutableArray alloc ] init ];
	menuArray  = [[ NSMutableArray alloc ] init ];
	formatterArray = [[ NSMutableArray alloc ] init ];

	[ fieldArray addObject: baseField1 ];
	[ fieldArray addObject: baseField2 ];
	[ fieldArray addObject: baseField3 ];
	[ fieldArray addObject: baseField4 ];
	[ fieldArray addObject: baseField5 ];
	[ fieldArray addObject: baseField6 ];
	[ fieldArray addObject: baseField7 ];
	[ fieldArray addObject: baseField8 ];
	
	[ menuArray addObject: baseMenu1 ];
	[ menuArray addObject: baseMenu2 ];
	[ menuArray addObject: baseMenu3 ];
	[ menuArray addObject: baseMenu4 ];
	[ menuArray addObject: baseMenu5 ];
	[ menuArray addObject: baseMenu6 ];
	[ menuArray addObject: baseMenu7 ];
	[ menuArray addObject: baseMenu8 ];

	count = [ menuArray count ];
	
	
	for(i=0; i<count; i++) {
		
		field = [ fieldArray objectAtIndex: i ];
		menu  = [ menuArray objectAtIndex: i ];
		formatter = [[ HTFormatter alloc ] init ];
		
		[ menu removeAllItems ];
		[ formatterArray addObject: formatter ];
		[ field setFormatter: formatter ];

		[ formatter release ];

		for(base=1; base<37; base ++) {
			
			NSString * str;
			
			if(labels[base])
				str = [[ NSString alloc ] initWithString: labels[base] ];
			else
				str = [[ NSString alloc ] initWithFormat:@"Base %d",base ];
			
			[ menu addItemWithTitle: str ];
			
			[ str release ];
		}
	
	}

	for(i=0; i<count; i++ ) {
		NSString  * s;
		menu = [ menuArray objectAtIndex: i ];
		s = [[ NSString alloc ] initWithFormat:@"baseMenu%d",i+1 ];
		[ menu selectItemWithTitle: [ prefs stringForKey: s ]];
		[ s release ];
	
		[ self baseChanged: menu ];
		[[ fieldArray objectAtIndex: i ] setStringValue:@"" ];
	}

	calcMode = [ prefs integerForKey:@"calcMode" ];

	[ functionMatrix selectCellAtRow: 0 column: calcMode ];

}

- (void)dealloc
{
    [ fieldArray release ];
	[ menuArray release ];
	[ formatterArray release ];
	[ prefs release ];
    [super dealloc];
}

- (void)windowWillClose:(NSNotification *)aNotification
{
	[ NSApp stop: self ];
}

- (IBAction) setMode:(int) mode with:(id) sender
{
	NSRect r;
	NSSize s;
	NSWindow * mw;
	
	uiMode = mode;
	
	mw = [ NSApp mainWindow ];
	r = [ mw frame ];
	[ prefs setInteger: mode forKey:@"UIMode" ];
	
	if( mode == HT_ADVANCED ) {
		r.size.height = HT_ADVANCED_Y;
		[ sender setTitle:@"Basic" ];
		[ sender setNextKeyView: baseMenu6 ];
	} else {
		r.size.height = HT_BASIC_Y;
		[ sender setTitle:@"Advanced" ];
		[ sender setNextKeyView: baseMenu1 ];
	}		
		
	[ mw setFrame: r display:YES animate: YES ];
	s = [ mw minSize ];
	s.height = r.size.height;
	[ mw setMinSize: s ];
	s.width = FLT_MAX;
	[ mw setMaxSize: s];
}

- (IBAction) setMode:(id) sender
{
	NSRect r;
	NSWindow * mw;
	
	mw = [ NSApp mainWindow ];
	r = [ mw frame ];
	
	if( r.size.height == HT_BASIC_Y )
		[ self setMode: HT_ADVANCED with: sender ];
	else
		[ self setMode: HT_BASIC with: sender ];
}


- (void)windowDidBecomeMain:(NSNotification *)aNotification
{
	uiMode = [ prefs integerForKey:@"UIMode" ];
	[ self setMode: uiMode with: modeButton ];
}

@end
