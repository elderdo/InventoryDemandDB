#include <stdio.h>
/*  
* xor-crypt.c
* Author: Douglas Elder
* Date: 6/16/2010
* Description: this is a DOS command line
* tool used to encrypt a file using a simple
* key as the first argment.
* The app defaults to stdin and stdout 
* if files are not specified on the command line.
*
* example
* using a DOS Commonad Prompt Window
* xor-crypt secrectKey101 myinputfile.txt myoutputfile.txt
*
* this will scramble the contents of myinputfile.txt and
* write it out to myoutputfile.txt
*
* xor-crypt secretKey101 myoutputfile.txt
*
* this should unscramble the file and write the original
* contents of myinputfile.txt  to stdout ( the DOS Command Prompt Window )
* Rev 1.0 initial release 6/16/2010
* Rev 1.1 added header comments and code comments 11/10/2014
**/

int main( int argc, char *argv[] ) {

  FILE *in, *out;
  char *key;
  int byte;

  if( argc <= 1 ) {
    /* nothing was entered on the command line so explain how to use this app */
    printf( "Usage: xor-crypt <key> <input_file> <output_file>\n" );
    return 1;
  }

  /* the key is required and should be the first argument specified on the command line after xor-crypt */
  key = argv[1];

  /* open the input file and default to stdin if no file is specified on the command line */
  if( ( in = (argc >= 3) ? fopen( argv[2], "rb" ) : stdin ) != NULL ) {
    /* open the output file and default to stdout if no file is specified on the command line */
    if( ( out = (argc == 4) ? fopen( argv[3], "wb" ) : stdout ) != NULL ) {
      while( ( byte = getc(in) ) != EOF ) {
        if( !*key ) key = argv[1];
          byte^= *(key++);
        putc( byte,out );
      }
      fclose( out );
    }
    fclose( in );
  }
 return 0;
}

