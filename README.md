# The Cadastral Crawler  

A prototype geospatial PostGIS/Shiny-Server application for exploring relationships in land ownership and property records.  
  
# Philosophical Motivations  

> We are segmented from all around and in every direction. The human being is a segmentary animal. Segmentarity is inherent to all the strata composing us. Dwelling, getting around, working, playing: life is spatiall and socially segmented. The house is segmented according to its rooms' assigned purposes; streets, according to the order of the city; the factory, according to the nature of the work and operations performed in it.  
> - Deluze and Guattari, *A Thousand Plateaus: Capitalism and Schizophrenia* (1987)
  
> It has always been this way with the map-makers: from their first scratches on the cave wall to show the migration patterns of the herds, they have traced lines and lived inside them. 
> -Maya Sonenberge, *Cartographies* (1989)  

> ...maps provide the very conditions of possibility for the worlds we inhabit and the subjects we become.  
> - John Pickles, *A History of Spaces* (2004)  

Geography, they say, is the discipline of mapping the earth. It is supposedly a discipline of reading and transcribing the surface of the earth onto a the surface of a map. Fewer people seem to recognize that geography is also primary the mechanism by which human beings *inscribe human social divisions onto the earth's surface*.  
  
Take a common example: a large, multi-acre parcel is sold off to a corporate developer to developmen into a neighborhood of single-family residential homes. The developer hires licensed surveyors to subdivide the single multiacre parcel into small, individual lots. Once the indivual lots are subdivided on an abstract map, a veritable army of humans begins to alter the earth's surface to fit. Road and utility conduits are constructed to follow the boundaries of the subdivided parcels, connecting each parcel to the wider civic infrastructure. The lots are sold to prospective home owners who, once they own the parcel, begin alter the landscape. They change the landscape inside their parcel, cutting and filling the earth and replanting the native vegetation with gardens and decorative plants. Homeowners are also - barring rules or laws against it - notorious for fencing the boundaries of the parcel to keep out casual trespassers and insure privacy against the nosy neighbors. 
  
Reality, in other words, is altered to suit the abstract lines drawn on a map. An entire army of people - from surveyors to realators to engineers to landscapers and fence builders - work together to inscribe the abstract boundaries of the cadastral map into tangible boundaries on the surface of the earth.
  
The cadastral map of property ownership is an enormously important and largely unseen structural force that organizes the *hows* and *whys* of modern economic, political, and social life. As an anonymous wag once put it, "they aren't making land anymore" and the boundaries of who owns what land *now* constrain what can happen in the future.  
  
For the most part, the middle class's terminal dream of owning their own little piece of property is almost entirely extraneous to the production of the cadastral map. The middle class is left to purchase the remnant parcels that the big players - large corporations and the wealthiest individuals - deign to subdivide and sell at a profit. Large parcels
  
The big players in the property market often one or more semi-anonymous corporate and legal entities to acquire and hold various parcels. Unlike the middle class - who, like the feudal serf, if often (legally) bound directly to the land they inhabit

## The Shell Game of Land Ownership  

Once upon a time, Walt Disney became discontent with the numerous fast food joints and hotels that sprang up just outside the gates of his California park. So Disney began a secret project to build a new park in the middle of the orange groves in central Florida. His goal was to acquire enough land that he could buffer his park from other landowners and control every facet of his customer's experience once inside the boundaries of the land he owned.  

Fearing that speculators and local landowners would drive up the price of parcels once they got wind of his land purchases, Disney used several shell corporations until he was ready to announce his plans to the world. After he owned a significant fraction of the local parcels, Disney leveraged his ownership into political and economic concessions from the State of Florida. Today, the Reedy Creek Improvement District is 38.6 square miles in area, and it is one of the few coporate municipalities in the nation - meaning the Disney Corporation via Reedy Creek is the local government.  
  
This is why Disney is Florida's 68th county: the corporation leveraged their land ownerhsip into political power. The state has granted Reedy Creek all of the powers of local government and then some. Disney runs the local fire services, as well as the corporate town of Celebration. Reed Creek was given the power to create their own police force, although they have not yet done so to date. Most startlingly, Reedy Creek was [granted the power to construct their own nuclear powerplant without first getting approval from the State and County governments](https://www.bloomberg.com/news/articles/2019-05-15/disney-world-s-literal-nuclear-option-explained).  

Disney's shell game is by no means unique - it is, in fact, incredibly common to own land indirectly through a semi-anonymous or anonymous legal entity like a corporation. Incorporating in Florida is extremely easy, and requires only three things: around $200 in spare cash, a template for the new companies articles of incorporation, and less than 10 minutes of time to fill out the form on the internet. 

There are numerous reasons - legal, tax, and nefarious - the big players purchase and own land through proxy entities. Regardless of *why* someone owns land via a proxy corporation, however, the practice ultimately serves to obscure the true social, political, and economic power wielded by large land owners.

## Cracking the Shell Game  

Unlike public companies traded on the stock market, privately held companies are only required to report the barest minimum of data to the government - typically their articles of incorporation, a list of board members, and designated agent. For these reasons, the public record related to corporate ownership is virtually useless if you want to actually unravel who actually owns the 8.5+ million parcels in the State of Florida. 

Property ownership, however, is heavily a heavily legislated and regulated affair. State and county governments typically require a property owner to register an actual address where they can be reached by mail so the property owner can be contacted in the event a legal or tax dispute arises. Put another way, with $200 dollars and a a few minutes of time, anyone can obfuscate the *name* of who owns a property. All it takes is incorporating a pivate company and registering the parcel under this assumed business name. What you cannot do is obscure is the physical address where the actual owner is nominally "located" and can be reached via registered mail.  
  
This provides a crack in the anonymity of land owners that can be exploited.  
  
## Rhizomatic Analysis  
> Unlike trees or their roots, the rhizome connects any point to any other point.. its traits are not necessarily linked to traits of the same nature.  
> - Deleuze and Guattari, *A Thousand Plateaus: Capitalism and Schizophrenia* (1987)  

The wrong way to approach the question of anonymous land ownership is to approach it in an *aboreal* manner. This is akin to the way a tree grows - we try to impose a predefined, heirarchical relationship between corporate registrations and land ownership, with a centeral trunk surrounded by increasingly smaller branches of subsidiary or satellite companies (which might themselves have their own, smaller, subsidiary branch companies).  
This application takes a *rhizomatic* approach. It builds links horizontal links between between parcel ownership using the owner address data using nothing but the parcel data itself.  

The process works like this:  
  
  1. Search parcels owned by a particular land owner by name.
  2. name and return all owner addresses registered.  
  2. For each parcel
  


  

  

  

 

  

