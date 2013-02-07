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

#import "Floor.h"
#define DEGTORAD 0.0174532925199432957f
#define RADTODEG 57.295779513082320876f

@implementation Floor

+(Floor*) floorSprite:(NSString *)shapeName spriteName:(NSString *)spriteName
{
    return [[[self alloc] initWithKinematicBody:shapeName spriteFrameName:spriteName] autorelease];
    //return [[[self alloc] initWithStaticBody:shapeName spriteFrameName:spriteName] autorelease];

}

-(void)turn:(float)atAngle
{

  b2Vec2 pos = body->GetPosition();
  body->SetTransform(pos, -1*CC_DEGREES_TO_RADIANS(atAngle));
  
//  float bodyAngle = body->GetAngle();
//  
//  float desiredAngle = -1*CC_DEGREES_TO_RADIANS(atAngle);
//  float nextAngle = bodyAngle + body->GetAngularVelocity() / 60.0;
//  float totalRotation = desiredAngle - nextAngle;
//  while ( totalRotation < -180 * DEGTORAD ) totalRotation += 360 * DEGTORAD;
//  while ( totalRotation >  180 * DEGTORAD ) totalRotation -= 360 * DEGTORAD;
//  float desiredAngularVelocity = totalRotation * 60;
//  float change = 1 * DEGTORAD; //allow 1 degree rotation per time step
//  desiredAngularVelocity = min( change, max(-change, desiredAngularVelocity));
//  float impulse = body->GetInertia() * desiredAngularVelocity;
//  body->ApplyAngularImpulse( impulse );
  //body->SetAngularVelocity(-60*DEGTORAD);
  
  
}

-(b2Vec2)rotate:(float)theta around:(b2Vec2)origin
{
  b2Vec2 pos = body->GetPosition();
//  float l = ABS(pos.x - origin.x);
//  
//  float dx = l*cosf(withAngle);
//  float dy = l*sinf(withAngle);
//  
//  float newx = origin.x + dx;
//  float newy = origin.y - dy;
  
  float newx = cosf(theta) * (pos.x-origin.x) - sinf(theta) * (pos.y-origin.y) + origin.x;
  float newy = sinf(theta) * (pos.x-origin.x) + cosf(theta) * (pos.y-origin.y) + origin.y;
  
  body->SetTransform(b2Vec2(newx, newy), CC_DEGREES_TO_RADIANS(theta));
  return b2Vec2(newx, newy);
  
}

-(void)transform:(b2Vec2)pos withAngle:(float)theta
{
   body->SetTransform(pos, -CC_DEGREES_TO_RADIANS(theta));
}

-(b2Body*)getbody
{
  return body;
}

-(void)remove
{
    [[self ccNode] removeFromParentAndCleanup:YES];
    [self destroyBody];
}


@end
