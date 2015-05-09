/*
 Copyright (c) 2011, OpenEmu Team
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
     * Redistributions of source code must retain the above copyright
       notice, this list of conditions and the following disclaimer.
     * Redistributions in binary form must reproduce the above copyright
       notice, this list of conditions and the following disclaimer in the
       documentation and/or other materials provided with the distribution.
     * Neither the name of the OpenEmu Team nor the
       names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY OpenEmu Team ''AS IS'' AND ANY
 EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL OpenEmu Team BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "OEDBSmartCollection.h"
#import "OETheme.h"

@implementation OEDBSmartCollection

+ (NSString *)entityName
{
    return @"SmartCollection";
}

#pragma mark - Sidebar Item Protocol
- (NSImage *)sidebarIcon
{
    return [[OETheme sharedTheme] imageForKey:@"collections_smart" forState:OEThemeStateDefault];
}

- (BOOL)isEditableInSidebar
{
    return YES;
}

- (NSString *)sidebarName
{
    if([self OE_isRecentlyAddedCollection])
    {
        return NSLocalizedString(@"Recently Added", @"Recently Added Smart Collection Name");
    }
    return [self valueForKey:@"name"];
}

- (void)setSidebarName:(NSString *)newName
{}

- (NSString*)editItemDefinitionMenuItemTitle
{
    return NSLocalizedString(@"Edit Smart Collection", @"Edit smart collection sidebar context menu item");
}

#pragma mark - Game Collection View Item
- (NSString *)collectionViewName
{
    if([self OE_isRecentlyAddedCollection])
    {
        return NSLocalizedString(@"Recently Added", @"Recently Added Smart Collection Name");
    }
    return [self valueForKey:@"name"];
}

- (BOOL)isCollectionEditable
{
    return NO;
}

- (BOOL)shouldShowSystemColumnInListView
{
    return YES;
}

- (NSPredicate *)fetchPredicate
{
    return [NSPredicate predicateWithFormat:[self fetchPredicateFormat]];
}

- (NSArray*)fetchSortDescriptors
{
    NSArray *parts = [[self fetchSortKey] componentsSeparatedByString:@"."];
    const NSRange keyRange = NSMakeRange(0, [parts count]-1);

    NSString *direction = [parts lastObject];
    NSString *key = [[parts subarrayWithRange:keyRange] componentsJoinedByString:@"."];

    if([key length])
    {
        BOOL descending = [direction length] && [[direction uppercaseString] isEqualToString:@"DSC"];
        return @[[NSSortDescriptor sortDescriptorWithKey:key ascending:!descending]];
    }

    return @[];
}

- (NSFetchRequest*)fetchRequest
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    [request setPredicate:[self fetchPredicate]];
    [request setSortDescriptors:[self fetchSortDescriptors]];
    NSNumber *limit = [self fetchLimit];
    if(limit)
        [request setFetchLimit:[limit unsignedIntegerValue]];

    return request;
}

#pragma mark - Private Methods
- (BOOL)OE_isRecentlyAddedCollection
{
    return [[self valueForKey:@"name"] isEqualToString:@"Recently Added"];
}

#pragma mark - Core Data Properties
@dynamic fetchLimit;
@dynamic fetchPredicateFormat;
@dynamic fetchSortKey;
@end
