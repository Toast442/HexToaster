/*
 This file is part of HexToaster, an OS X Numeric Base Converter

 Copyright (C) 2018 Jason Kingan
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

/* HTFormatter */

#import <Cocoa/Cocoa.h>

@interface HTFormatter : NSFormatter
{
    int m_Base;
}
-(void)setBase:(int)base;
-(int)getBase;
-(NSString *)stringForObjectValue:(id)anObject;
-(BOOL)getObjectValue:(id *)anObject forString:(NSString *)string errorDescription:(NSString **)error;
-(BOOL)isPartialStringValid:(NSString *)partialString newEditingString:(NSString **)newString errorDescription:(NSString **)error;

@end
