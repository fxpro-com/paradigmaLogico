/* Program to Save a True Metafile as a "Placeable" Metafile - BDS 09 Mar 94
   =========================================================================

   Windows metafiles are special resource files containing a sequence of
   graphics output commands, and can be used to port vector-based images
   between different applications. Unfortunately, some applications
   (such as Microsoft Word for Windows) are unable to process these files
   unless the include an additional header which specifies the size and
   scaling factor of the metafile. Equally unfortunate is that such metafiles
   cannot be loaded using standard Windows API calls without first discarding
   this header!

   The following program uses Windows API calls to create a "True" metafile,
   and then uses Prolog I/O to create the "placeable" header. Using this
   program, you will be able to export Prolog graphics to Word and other
   Microsoft applications.
 */

save_metafile(File,Grafix,X0,Y0,X1,Y1) :-
  wxcreate(temp,Grafix,X0,Y0,X1,Y1),	% create memory metafile
  wxsave(temp,temp),			% save it to disk
  wxclose(temp),			% delete memory metafile
  H0 = 16'cdd7,				% magic number - key sig part 1
  H1 = 16'9ac6,				% magic number - key sig part 2
  H2 = 0,				% magic number - reserved (must be 0)
  H3 = X0,				% left logical bounding coordinate
  H4 = Y0,				% top logical bounding coordinate
  H5 = X1,				% right logical bounding coordinate
  H6 = Y1,				% bottom logical bounding coordinate
  H7 = 1000,				% number of logical units per inch
  H8 = 0,				% magic number - reserved (must be 0)
  H9 = 0,				% magic number - reserved (must be 0)
  rpn([H0,H1,x,H2,x,H3,x,H4,x,H5,x,H6,x,H7,x,H8,x,H9,x],Check), % checksum
  fopen(temp,temp,0),			% open temp true metafile
  fcreate(File,File,0),			% create named placeable metafile
  input(temp),				% set temp for input
  output(File),				% set named file for output
  putx(2,H0),				% output header word 0
  putx(2,H1),				% output header word 1
  putx(2,H2),				% output header word 2
  putx(2,H3),				% output header word 3
  putx(2,H4),				% output header word 4
  putx(2,H5),				% output header word 5
  putx(2,H6),				% output header word 6
  putx(2,H7),				% output header word 7
  putx(2,H8),				% output header word 8
  putx(2,H9),				% output header word 9
  putx(2,Check),			% output header checksum
  copy(-1,Bytes),			% copy true metafile to output
  fclose(temp),				% close temp metafile
  fclose(File),				% close placeable metafile
  del(temp),				% delete temp file
  write('Placeable Metafile "'),	% output assorted details...
  write(File),
  write('" created with '),
  write(Bytes),
  write(' graphics bytes'),
  nl.					% and that's it!
