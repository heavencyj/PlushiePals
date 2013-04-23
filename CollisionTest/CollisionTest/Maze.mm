/*
 MIT License
 
 Copyright (c) 2010 Andreas Loew / www.code-and-web.de
 
 For more information about htis module visit
 http://www.PhysicsEditor.de
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "Maze.h"
#define DEGTORAD 0.0174532925199432957f
#define RADTODEG 57.295779513082320876f

@implementation Maze

+(Maze*) mazeSprite:(NSString *)shapeName spriteName:(NSString *)spriteName
{
    return [[[self alloc] initWithKinematicBody:shapeName spriteFrameName:spriteName] autorelease];
}

-(void)transform:(b2Vec2)pos withAngle:(float)theta
{
  float angle = body->GetAngle();
  body->SetTransform(pos, -CC_DEGREES_TO_RADIANS(theta)+angle);
}

-(void)remove
{
    [[self ccNode] removeFromParentAndCleanup:YES];
    [self destroyBody];
}

-(void)moveTo:(b2Vec2)pos
{
    body->SetTransform(pos, body->GetAngle());
}

-(void)setMazeBodySensor:(BOOL)sensor
{
    for (b2Fixture *f=body->GetFixtureList(); f->GetNext() != nil; f=f->GetNext()) {
        NSString *fixtureId = (NSString*)f->GetUserData();
        if ([fixtureId isEqualToString:@"mazebody"]) {
            f->SetSensor(sensor);
            break;
        }
    }
}

-(b2Body*)getBody
{
    return body;
}

- (void) dealloc
{
	[super dealloc];
}
@end
