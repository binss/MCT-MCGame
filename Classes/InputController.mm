//
//  InputControllerViewController.m
//  MCGame
//
//  Created by kwan terry on 12-10-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InputController.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "CoordinatingController.h"
@implementation InputController
@synthesize tapCount;
@synthesize touchEvents;
@synthesize fsm_Current_State,fsm_Previous_State;
//@synthesize isNeededReload;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)niMCundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:niMCundleOrNil]) {
		// init our touch storage set
		touchEvents = [[NSMutableSet alloc] init];
		fsm_Current_State = kState_None;
        fsm_Previous_State = kState_None;
        tapCount = 0;
  //      isNeededReload=NO;
	}
	return self;
}
-(void)loadView
{
	
}

-(CGRect)screenRectFromMeshRect:(CGRect)rect atPoint:(CGPoint)meshCenter
{
	// find the point on the screen that is the center of the rectangle
	// and use that to build a screen-space rectangle
	CGPoint screenCenter = CGPointZero;
	CGPoint rectOrigin = CGPointZero;
	// since our view is rotated, then our x and y are flipped
	screenCenter.x = meshCenter.x + 512.0; // need to shift it over
	screenCenter.y = meshCenter.y - 384.0; // need to shift it up
    screenCenter.y = -screenCenter.y;
	rectOrigin.x = screenCenter.x - (CGRectGetWidth(rect)/2.0); // height and width 
	rectOrigin.y = screenCenter.y - (CGRectGetHeight(rect)/2.0); // are flipped
    return CGRectMake(rectOrigin.x, rectOrigin.y, CGRectGetWidth(rect), CGRectGetHeight(rect));
}


#pragma mark Touch Event Handlers

// just a handy way for other object to clear our events
- (void)clearEvents
{
	[touchEvents removeAllObjects];
}
#pragma mark touches
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    
    tapCount = 0;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //轨迹跟踪粒子
    UITouch* touch = [[touches allObjects] objectAtIndex:0];
    CGPoint location = [touch previousLocationInView:self.view];
    particleEmitter.translation = MCPointMake(location.x-512, -(location.y-384),-1);
    particleEmitter.emit = YES;
    //手势识别状态
    if ([touches count]==1) {
        tapCount++;
    }else if([touches count]==2){
        tapCount++;
        tapCount++;
    }
    if ([touches count]>2) {
        return;
    }
    
    //正常1
    if (tapCount==1&&fsm_Previous_State==kState_None) {
        fsm_Previous_State = kState_None;
        fsm_Current_State = kState_S1;
        // just store them all in the big set
        
    }
    //单手异常
    if (tapCount==2&&(fsm_Current_State==kState_M1)) {
        fsm_Current_State = kState_F1;
        fsm_Previous_State = kState_None;
        tapCount = 0 ;
        
    }
   
    //双手
    if (tapCount==2&&(fsm_Current_State==kState_S1)) {
        fsm_Current_State = kState_S2;
        fsm_Previous_State = kState_None;
        // just store them all in the big set.
        //[touchEvents addObjectsFromArray:[touches allObjects]];
       
    }else  //双手
        if (tapCount==2&&(fsm_Previous_State==kState_None)) {
            fsm_Current_State = kState_S2;
            fsm_Previous_State = kState_None;
            // just store them all in the big set.
            //[touchEvents addObjectsFromArray:[touches allObjects]];
        }
    [touchEvents addObjectsFromArray:[touches allObjects]];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count]>2) {
        return;
    }
    
    //轨迹跟踪粒子
    UITouch* touch = [[touches allObjects] objectAtIndex:0];
    CGPoint location = [touch previousLocationInView:self.view];
    particleEmitter.translation = MCPointMake(location.x-512, -(location.y-384),-1);
    
    //单层正常
    if (tapCount==1&&fsm_Current_State == kState_S1) {
        fsm_Previous_State = fsm_Current_State;
        fsm_Current_State = kState_M1;
        //[touchEvents addObjectsFromArray:[touches allObjects]];
    }
    if (tapCount==1&&fsm_Current_State == kState_M1) {
    }
    //
    
    if (tapCount==2&&[touches count]!=2) {
        return;
    }
    
    //视角变换
    if (tapCount==2&&fsm_Current_State == kState_S2) {
        fsm_Previous_State = fsm_Current_State;
        fsm_Current_State = kState_M2;
    }
    if (tapCount==2&&fsm_Current_State == kState_M2) {
    }

    /*
    if ([touches count]==1&&fsm_Current_State == kState_M2) {
        fsm_Previous_State = kState_None;
        fsm_Current_State = kState_F2;
        NSLog(@"8");
    }*/
    /*
    if ([touches count]==1&&fsm_Current_State == kState_S2) {
        fsm_Previous_State = fsm_Current_State;
        fsm_Current_State = kState_M2;
        NSLog(@"7");
    }*/

    // just store them all in the big set.
	[touchEvents addObjectsFromArray:[touches allObjects]];
     
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if ([touches count]>2) {
        return;
    }
    //轨迹跟踪粒子
    UITouch* touch = [[touches allObjects] objectAtIndex:0];
    CGPoint location = [touch previousLocationInView:self.view];
    particleEmitter.translation = MCPointMake(location.x-512, -(location.y-384),-1);
    particleEmitter.emit = NO;
    //单层正常结束
    //NSLog(@"[touches count]=%d",[touches count]);
    if (tapCount==1&&fsm_Current_State==kState_M1) {
        fsm_Current_State = kState_F1;
        fsm_Previous_State = kState_None;
        tapCount=0;
    }
    
    if (tapCount==2&&fsm_Current_State==kState_M2) {
        fsm_Previous_State = kState_None;
        fsm_Current_State = kState_F2;
        tapCount=0;
        [self clearEvents];
    }
    if ((fsm_Current_State == kState_S2)&&(fsm_Previous_State==kState_None)) {
        fsm_Previous_State = kState_None;
        fsm_Current_State = kState_F2;
        tapCount =0;
    }
    if (tapCount>0) {
        tapCount--;
    }
    
	// just store them all in the big set.
	[touchEvents addObjectsFromArray:[touches allObjects]];

    
}
#pragma mark Autorotate
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIDeviceOrientationLandscapeRight);
}



#pragma mark unload, dealloc

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void)loadInterface
{
	//implemented by sub class
    particleEmitter = [[MCParticleSystem alloc] init];
	particleEmitter.emissionRange = MCRangeMake(1.0, 0.0);
	particleEmitter.sizeRange = MCRangeMake(8.0, 0.0);
	particleEmitter.growRange = MCRangeMake(-0.5, 0.0);
	
	particleEmitter.xVelocityRange = MCRangeMake(0.0, 0.0);
	particleEmitter.yVelocityRange = MCRangeMake(0.0, 0.0);
	
	particleEmitter.lifeRange = MCRangeMake(5, 0.0);
	particleEmitter.decayRange = MCRangeMake(0.02, 0.00);
    
	[particleEmitter setParticle:@"lightBlur"];
	particleEmitter.emit = NO;
    [[[CoordinatingController sharedCoordinatingController] currentController]addObjectToScene:particleEmitter];    

}

-(void)updateInterface
{
	[interfaceObjects makeObjectsPerformSelector:@selector(update)];
}


-(void)renderInterface
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	//glRotatef(-90.0f, 0.0f, 0.0f, 1.0f);
	
	// set up the viewport so that it is analagous to the screen pixels
	glOrthof(-512, 512, -384, 384, -1.0f, 50.0f);
	glMatrixMode(GL_MODELVIEW);
	glDisable(GL_LIGHTING);
	glDisable(GL_CULL_FACE);
    //	glCullFace(GL_FRONT);
    glEnable(GL_DEPTH_TEST);
	// simply call 'render' on all our scene objects
	[interfaceObjects makeObjectsPerformSelector:@selector(render)];
    
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
    
}

-(void)releaseSrc{
    [interfaceObjects removeAllObjects];
}


- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (void)dealloc 
{
	[touchEvents release];
	[super dealloc];
}
@end
