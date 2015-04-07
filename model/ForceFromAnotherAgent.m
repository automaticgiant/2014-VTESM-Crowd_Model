% 1;


% do we want equal and opposite forces?
% line of sight, sweep out an arc would be ideal...
function ForceVector = ForceFromAnotherAgent(AgentPosVector, AgentVelVector, OtherPosVector, VelOther, forceFromGoal)
  % lets assume distances are calculated in mm
  % a person is about... 500mm wide (so radius is 250mm)
  %disp('in force function')
  % maybe this function shouldnt be called for 2 people in a group, and they should have their own function, each agent could hold a list of other agents they are 'grouped' with or something
  distence = norm(AgentPosVector-OtherPosVector);
  %distence = sqrt((AgentPosVector(1)-OtherPosVector(1))^2 + (AgentPosVector(2)-OtherPosVector(2))^2)
  relativePosOfOther = OtherPosVector - AgentPosVector;
  % relativePosOfOther = [OtherPosVector(1)-AgentPosVector(1) , OtherPosVector(2)-AgentPosVector(2)]
  % we may want to specify persons size in the config files? (ie let user change it)
  % maybe each agent has a diff number here in if statement for size 
  angleOfSight = 1;
  %1 for right, -1 for left
  % this is for when two ppl are moving approx straight at each other
  theSign = sign(cross([forceFromGoal(1), forceFromGoal(2) ,0], [relativePosOfOther, 0]));
  %dodgeSideways = abs(dot(forceFromGoal, VelOther));
  if (theSign(3) == 0)
    theSign = [0,0,-1];
  end
  % both directions have force which means agent has moved past edge points of goal
  % so we have been dodgeing the wrong way
  %if (abs(forceFromGoal(1)) > 1 && abs(forceFromGoal(2)) > 1)
    %theSign = -1*theSign;
  %end
  if (norm(AgentVelVector) > 0)
    % calculate angle between vel and other's pos, assume agent is looking in direction of goal 
    % line of sight
  angleOfSignt = dot(forceFromGoal,OtherPosVector)/norm(forceFromGoal)/norm(OtherPosVector);
  end
  
  if (distence <= 500)
    %disp('colision')
    %people would bump, special handeling? 
    %force should be "infinite" bc agents cannot move closer 
    % should we output # of collisions for user data?
    if (distence < 50 ) % if two points are exactly on top it breaks... this should never happen but
      ForceVector = [(rand - 0.5)*3000, (rand - 0.5)*3000];
    else%if (dodgeSideways < 1/2)
    	%ForceVector = relativePosOfOther*-0.05*(10000+1/((distence+50)))-500*VelOther;
    %else
      ForceVector = relativePosOfOther*-0.04*(10000+1/((distence+50)))  +0.3*goRight(theSign(3)*forceFromGoal);
    end
  
  % probably want another elseif here to check line of sight (theta = acos( v1.v2) / |v1||v2|).  we still want to check if people hit bc line of sight doesnt effect that.  but if people dont see each other these forces dont matter... unless talking group stuff... 
  % should groups be handled in this function or another function designed spcifically for groups?
  elseif (angleOfSight > 0) % person has 180 view
    if (distence <= 1500)
      %disp('repel')
      % the repulsion zone
      % if forming a group this distence is too large probably 
      % this is less then a meter shoulder to shoulder
      force = 1000/((distence+500)/2000)^3*0.02; %1000-8000
      %if (dodgeSideways < 1/2)
    	%ForceVector = force*relativePosOfOther/distence*-1 -500*VelOther;
      %else
      ForceVector = force*relativePosOfOther/distence*-1 +0.3*goRight(theSign(3)*forceFromGoal);
      %end
      % something should be done here with velocity so people moving towords each other 'prepare' to dodge, and someone can 'pass' another person if v in same direction etc
      % determine probability of wanting to 'dodge' right or left (culture) (should user set this?)
    elseif (distence <= 10000)
      %disp('flock')
      %flocking
      %potentially form group? 
      if (norm(VelOther) > 0.1)
        
        ForceVector = 0.1*VelOther/norm(VelOther);
      else 
        ForceVector = [0,0];
      end
    else
      ForceVector = [0,0];
    end
    % adjust for line of sight
    ForceVector = ForceVector*angleOfSight;
  end
  
  
  
end

%!test % tests the force function for simple case flocking zone
%! assert( ForceFromAnotherAgent([0,0],[0,0],[3000,0],[1,0]) ,[20,0], 0.00001 )

%!test % tests the force function for repulsion zone, make 3,4,5 triangle for ez math
%! assert( ForceFromAnotherAgent([1100,1800],[0,0],[500,1000],[0,0]) ,[1/((1000-300)/1200)^3*3/5,1/((1000-300)/1200)^3*4/5], 0.00001 )

%!test % tests the force function for repulsion zone, make 3,4,5 triangle for ez math
%! assert( ForceFromAnotherAgent([500,1000],[0,0],[1100,1800],[0,0]) ,[-1/((1000-300)/1200)^3*3/5,-1/((1000-300)/1200)^3*4/5], 0.00001 )

%!test % tests the force function for simple case repulsion zone
%! assert( ForceFromAnotherAgent([0,0],[0,0],[1500,0],[0,0]) ,[-1/((1500-300)/1200)^3,0], 0.00001 )

%!test % tests the force function for simple case repulsion zone
%! assert( ForceFromAnotherAgent([0,0],[0,0],[1000,0],[0,0]) , [-1/((1000-300)/1200)^3,0] , 0.00001)

%!test % tests the force function for simple case repulsion zone
%! assert( ForceFromAnotherAgent([0,0],[0,0],[501,0],[0,0]) , [-1/((501-300)/1200)^3,0] , 0.00001)

% test ForceFromAnotherAgent.m