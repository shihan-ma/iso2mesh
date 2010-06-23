function [newno,newfc]=remeshsurf(node,face,opt)
%   [newno,newfc]=resurf(node,face,opt)
%
%   remesh a triangular surface and the output is guaranteed to be
%   free of self-intersecting element. This function is similar to 
%   meshresample, but it can both downsample or upsample a mesh
%
%   author: Qianqian Fang (fangq <at> nmr.mgh.harvard.edu)
%
%   inputs:
%          node: list of nodes on the input suface mesh, 3 columns for x,y,z
%          face: list of trianglular elements on the surface, [n1,n2,n3,region_id]
%          opt: function parameters
%            opt.gridsize:  resolution for the voxelization of the mesh
%            opt.closesize: if there are openings, set the closing diameter
%            opt.elemsize:  the size of the element of the output surface
%            if opt is a scalar, it defines the elemsize and gridsize=opt/4
%
%   outputs:
%          newno:  list of nodes on the resulting suface mesh, 3 columns for x,y,z
%          newfc:  list of trianglular elements on the surface, [n1,n2,n3,region_id]
%
% -- this function is part of iso2mesh toolbox (http://iso2mesh.sf.net)
%

p0=min(node);
p1=max(node);

if(isstruct(opt))
   if(isfield(opt,'gridsize'))
      dx=opt.gridsize;
   end
else
  dx=opt/4;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 1: convert the old surface to a volumetric image
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
img=surf2vol(node,face,p0(1)-dx:dx:p1(1)+dx,p0(2)-dx:dx:p1(2)+dx,p0(3)-dx:dx:p1(3)+dx);

eg=surfedge(face);
ballsize=0;

if(~isempty(eg) & isstruct(opt))
   if(isfield(opt,'closesize'))
     ballsize=opt.closesize;
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 2: fill holes in the 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

img=fillholes3d(img,ballsize);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% step 3: convert the filled volume to a new surface
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if(isstruct(opt))
   if(isfield(opt,'elemsize'))
      [newno,newfc]=v2s(img,0.5,opt.elemsize,'cgalsurf');
   end
else
  [newno,newfc]=v2s(img,0.5,opt,'cgalsurf');
end
