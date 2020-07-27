# The Cadastral Crawler  
  
> Unlike trees or their roots, the rhizome connects any point to any other point.. its traits are not necessarily linked to traits of the same nature.  
> - Deleuze and Guattari, *A Thousand Plateaus: Capitalism and Schizophrenia* (1987)  

This is prototype PostGIS/Shiny-Server application for exploring relationships in land ownership and property records. It is particularly suited for ferreting out the shell corporations and subsidiaries used by large land owners.

A live demo of the app can be found here: [http://67.205.144.203/cadcrawler](http://67.205.144.203/cadcrawler)
  
This software is licensed under the APGL v3.0. If you are interested in a commercial license and/or a custom application suited to your own need, please contact me directly at seth[dot]bassett[at]gmail[dot]com.  

# How the application works   

The true name of a land owner is trivial easy to hide: register a corporation and transfer the land to that legal entity. Registering a corporation takes less than $200 and 10 minutes in Florida. Private companies are not required to disclose ownership into public records.  
This application uses horizontal links between owner names and owner addresses to build potential links between parcel owners. By law, owners have to register a legal address where they can be reached for each parcel. Single owners that use subsidiaries to purchase often register one or more legal entitites to the same address. 

The Cadastral Crawler leverages the 1:m relationship between owner names and registered address to crawl through the cadastral record horizontally, building a directed graph network of the relationship between owner names and their registered addresses.  
  
# Known Limitations  
  
The process works well in many cases. In many others it does not. I make no claims to data quality and do not warranty this product in any way - its APGL licensed, so if it's broke fill out a bug report or fix it and submit a pull request.  
  
There are several known limitations to the current method:  
  
  * Cadastral records are notoriously poor, and data quality and standards vary by county.  
  * The cadastral data used in the application is the FGDL's parcels_2018 layer. This layer is plauged with multiple quality issues - longer company names have been truncated, for example.  
  * The process of matching names and addresses currently uses exact text matching. "NORTH FLORIDA LLC" and "N FLORIDA LLC" will appear as two different nodes in the directed graph output. This also applies to owner address nodes. (Fuzzy text matching and some interactive controls for merging nodes from the UI are planned for a future release.)  
  * There are many legitimate reasons that some owner addresses are registered to an enormous number of parcels or owner names. Government entities, utilities, and banks are all examples of legitimate, 'above board' large land owners that can form spurious links in the directed graph output.  
  

  
 
  

  



  


  

  

  

 

  

