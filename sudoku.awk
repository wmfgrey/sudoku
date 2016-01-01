#! /bin/gawk -f

############ sudoka.awk #########################
#
# DESCRIPTION: 	Solves Sudoka puzzles
#
# AUTHOR: 	William Grey
#
# LAST UPDATE: 	1 January 2006
#
# INPUT:	A file containing  the Sudoka 
#         	that we want to solve, 
#               corresponding to the 9 rows and 
#               columns. Zeros (0) are used for 
#          	empty boxes (i.e. the values we 
#               wish to find).
# 
# 		0 0 0 0 6 0 8 0 0
#		0 0 0 0 5 0 2 7 9
# 		0 4 0 7 0 3 0 0 0
# 		8 5 4 0 1 0 0 0 2
# 		0 9 0 0 0 0 0 8 0
# 		0 0 0 0 2 0 5 9 7
# 		0 0 0 6 0 8 0 5 0
# 		5 6 3 0 9 0 0 0 0
# 		0 0 1 0 4 0 0 0 0
#
# EXAMPLE: 	sudoka.awk < sudoka.dat
#
################################################

{
 # Reading the Sudoka into a 2D grid

 for (i=1;i<=9;i++)
  grid[i,NR]=$i
}

END{

 # Create a 9x9x9 3D matrix of rows, columns and
 # values, so that we can keep track of possible
 # and eliminated values for each box in the grid. 
 
 for (i=1;i<=9;i++)
  for (j=1;j<=9;j++)
   for (k=1;k<=9;k++)  
     val[i,j,k]=1

 # Set values in 3D matrix to 0 for 
 # grid numbers that we already have. 

  for (i=1;i<=9;i++){
   for (j=1;j<=9;j++){

    if(grid[i,j] != 0){
     for (k=1;k<=9;k++) 
      val[k,i,j]=0    
     val[grid[i,j],i,j]=1
    }   
   }
  }

#########################################

 # Keep looping until grid is completed 
 
 loop=1
 while(loop == 1){
 
 # Check against other values in rows, columns and subgrids
 # and eliminate values of a specific box accordingly.
 
  for (i=1;i<=9;i++){
   for (j=1;j<=9;j++){
    if (grid[i,j] == 0){
     
     # check row
     for (k=1;k<=9;k++) if(grid[k,j] != 0) val[grid[k,j],i,j]=0
     # check col
     for (k=1;k<=9;k++) if(grid[i,k] != 0) val[grid[i,k],i,j]=0

     if(i>=1 && i<=3) mstart=1
     if(i>=4 && i<=6) mstart=4
     if(i>=7 && i<=9) mstart=7
     if(j>=1 && j<=3) nstart=1
     if(j>=4 && j<=6) nstart=4
     if(j>=7 && j<=9) nstart=7
  
 # check that each value is the only value 
 # within the row, column, or subgrid     
   
    # check subgrid 
     for(m=mstart;m<=mstart+2;m++)
      for(n=nstart;n<=nstart+2;n++)
       if (grid[m,n] != 0) val[grid[m,n],i,j]=0
    
     # check row
     for (k=1;k<=9;k++){
      sum=0
      for (m=1;m<=9;m++) sum+=val[k,m,j]
      if (sum==1 && val[k,i,j]==1){
       for (m=1;m<=9;m++)val[m,i,j]=0
       grid[i,j]=k
       val[k,i,j]=1
      }
     }
     
     # check col
     for (k=1;k<=9;k++){
      sum=0
      for (m=1;m<=9;m++) sum+=val[k,i,m]
      if (sum==1 && val[k,i,j]==1){
       for (m=1;m<=9;m++)val[m,i,j]=0
       grid[i,j]=k
       val[k,i,j]=1  
      } 
     } 
     
     # check subgrid
     for (k=1;k<=9;k++){
      sum=0
      for(m=mstart;m<=mstart+2;m++)
       for(n=nstart;n<=nstart+2;n++) sum+=val[k,m,n]
      if (sum==1 && val[k,i,j]==1){
       for (m=1;m<=9;m++)val[m,i,j]=0
       grid[i,j]=k
       val[k,i,j]=1  
      } 
     }
 
    }
   }
  }
 
################################

 # Checks for twinning
flag=1
if (flag==1){

  for (i=1;i<=9;i++){
   for (j=1;j<=9;j++){
    if (grid[i,j] == 0){
     
     for (k=1;k<=9;k++)twin[k]=0
     for (k=1;k<=9;k++){
      sum=0
      for (m=1;m<=9;m++) sum+=val[k,m,j]
      if (sum==2) twin[k]=1
     }
      
      for (k1=1;k1<=9;k1++){
       for (k2=1;k2<=9;k2++){
        
        if((twin[k1]==1) && (twin[k2]==1) && (k1!=k2)){
         for (m1=1;m1<=9;m1++){
          for (m2=1;m2<=9;m2++){        
           if ((val[k1,m1,j]==1) && (val[k1,m2,j]==1) &&\
               (val[k2,m1,j]==1) && (val[k2,m2,j]==1) && m1!=m2){
           
           for (k=1;k<=9;k++){
             val[k,m1,j]=0
             val[k,m2,j]=0
           } 
           
            val[k1,m1,j]=1
            val[k2,m1,j]=1
            val[k1,m2,j]=1
            val[k2,m2,j]=1

          }
         }
        }
       }
      }    
     }     
 
     for (k=1;k<=9;k++)twin[k]=0
      for (k=1;k<=9;k++){
       sum=0
       for (m=1;m<=9;m++) sum+=val[k,i,m]
       if (sum==2) twin[k]=1
      }
      
      for (k1=1;k1<=9;k1++){
       for (k2=1;k2<=9;k2++){
       
        if((twin[k1]==1) && (twin[k2]==1) && (k1!=k2)){
         for (m1=1;m1<=9;m1++){
          for (m2=1;m2<=9;m2++){        
           if ((val[k1,i,m1]==1) && (val[k1,i,m2]==1) &&\
               (val[k2,i,m1]==1) && (val[k2,i,m2]==1) && m1!=m2){
          
           for (k=1;k<=9;k++){
             val[k,i,m1]=0
             val[k,i,m2]=0
           } 
           
            val[k1,i,m1]=1
            val[k2,i,m1]=1
            val[k1,i,m2]=1
            val[k2,i,m2]=1

          }
         }
        }
       }
      }    
     }
   
     if(i>=1 && i<=3) mstart=1
     if(i>=4 && i<=6) mstart=4
     if(i>=7 && i<=9) mstart=7
     if(j>=1 && j<=3) nstart=1
     if(j>=4 && j<=6) nstart=4
     if(j>=7 && j<=9) nstart=7

    for (k=1;k<=9;k++)twin[k]=0
      for (k=1;k<=9;k++){
       sum=0
       for(m=mstart;m<=mstart+2;m++)
        for(n=nstart;n<=nstart+2;n++) sum+=val[k,m,n]
       if (sum==2) twin[k]=1
      }
       
       for (k1=1;k1<=9;k1++){
        for (k2=1;k2<=9;k2++){
         
         if((twin[k1]==1) && (twin[k2]==1) && (k1!=k2)){
          for (m1=mstart;m1<=mstart+2;m1++){
           for (n1=nstart;n1<=nstart+2;n1++){
            for (m2=mstart;m2<=mstart+2;m2++){
             for (n2=nstart;n2<=nstart+2;n2++){         
            
            if ((val[k1,m1,n1]==1) && (val[k1,m2,n2]==1) &&\
                (val[k2,m1,n1]==1) && (val[k2,m2,n2]==1)){
           
            if ((m1!=m2) || (n1!=n2) ){
            for (k=1;k<=9;k++){
              val[k,m1,n1]=0
              val[k,m2,n1]=0
            } 
            
             val[k1,m1,n1]=1
             val[k2,m1,n1]=1
             val[k1,m2,n1]=1
             val[k2,m2,n1]=1
           }
           }
           }
           }
          }
         }
        }
       }    
      }
   
    }
   }
  }
 }

################################

 
 # Fill in grid boxes for values that we have found.  

 for (i=1;i<=9;i++){
   for (j=1;j<=9;j++){
    sum=0
    for (k=1;k<=9;k++) sum+=val[k,i,j]
     
    if(sum==1) for (k=1;k<=9;k++) if(val[k,i,j]==1) grid[i,j]=k
  
   }
  }
 
 # Check to see if grid is completed
 
 loop=0
 for(i=1;i<=9;i++)
  for(j=1;j<=9;j++)
   if(grid[i,j]==0) loop=1  
 
 num++ 
 print "Iteration ", num 
  
 for (j=1;j<=9;j++){
  for (i=1;i<=9;i++){
   printf grid[i,j]" "
  }
  printf "\n"
 }
 }

 printf "\nCompleted Sudoka \n" 
  
 for (j=1;j<=9;j++){
  for (i=1;i<=9;i++){
   printf grid[i,j]" "
  }
  printf "\n"
 } 


# printf "\n"
# for (k=1;k<=9;k++){
# for (i=1;i<=9;i++){
#  for (j=1;j<=9;j++){
#     printf val[k,i,j]" "
#  }
#  printf "\n"
# }
# printf "\n"
#}

}
