# The Cadastral Crawler  

This is prototype geospatial PostGIS/Shiny-Server application for exploring relationships in land ownership and property records that is particularly suited for ferreting out shell corporations used to hide large land purchases.  

A live demo of the app can be found here: **link to app**  
  
This version of the Cadastral Crawler software is licensed under the APGL v3.0. If you are interested in a commercial license and/or a custom application suited to your own need, please contact me directly at seth[dot]bassett[at]gmail[dot]com.  

# How the application works   

The true name of a land owner is trivial easy to hide: just register a corporation and transfer the land to that legal entity. Registering a corporation takes less than $200 and 10 minutes in Florida, and private companies are not required to disclose ownership into public records.  
  
However, every owner of a parcel has to register a legal address where they can be reached by the State of Florida, whether for taxation or legal disputes.  

This application takes a **rhizomatic** approach to the question of parcel ownership by exploiting the owner's recorded physical address.  It builds horizontal links between parcel owners by using the owner address data. 
  
The idea is this:  
  + take any given owner name registered to a parcel, Owner (A)
  + search the cadastral records for all parcels owned under that name, and compile a list of owner addresses used by that owner: Addresses (1, 2, 3)
  + use Addresses (1, 2, 3) and search the cadastral records again, this time compiling all Owner Names associated with those addresses. This gives us Owners (B, C, D)
  + repeat the process until the maximum search depth is reached or the search tree is exhausted, whichever comes first  
    
For more information and why this logic works exceptionally well at ferreting out subsidary and shell corporation used by big players in the Florida property market, see the **Background** section below.  
  
# How to install  
  
At present, you can't. This application is in early-stage development. I'm currently building towards Beta release v1.0, which will be dockerized for easy deployment.  

# Background Theory  

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
  
For the most part, the middle class's terminal dream of owning their own little piece of property is almost entirely extraneous to the production of the cadastral map. The middle class is left to purchase the remnant parcels that the big players - large corporations and the wealthiest individuals - deign to subdivide and sell at a profit. 
  
The big players in the property market often one or more semi-anonymous corporate and legal entities to acquire and hold various parcels. Unlike the middle class - who, like the feudal serf, are often (legally) bound directly to the land they inhabit - the big players own a significant amount of real property tied to them via private companies and their subsidiaries.  
  
The purpose of this app is to shed light onto the big players in the Florida property market and pierce the veil of semi-anonymous shell companies that help obfuscate who truly owns a property.  

## The Shell Game

Once upon a time, Walt Disney became discontent with the numerous fast food joints and hotels that sprang up just outside the gates of his California park. So Disney began a secret project to build a new park in the middle of the orange groves in central Florida. His goal was to acquire enough land that he could buffer his park from other landowners and control every facet of his customer's experience once inside the boundaries of the land he owned.  

Fearing that speculators and local landowners would drive up the price of parcels once they got wind of his land purchases, Disney used several shell corporations until he was ready to announce his plans to the world. After he owned a significant fraction of the local parcels, Disney leveraged his ownership into political and economic concessions from the State of Florida. Today, the Reedy Creek Improvement District is 38.6 square miles in area, and it is one of the few coporate municipalities in the nation - meaning the Disney Corporation via Reedy Creek is the local government.  
  
This is why Disney is Florida's 68th county: the corporation leveraged their land ownerhsip into political power. The state has granted Reedy Creek all of the powers of local government and then some. Disney runs the local fire services, as well as the corporate town of Celebration. Reed Creek was given the power to create their own police force, although they have not yet done so to date. Most startlingly, Reedy Creek was [granted the power to construct their own nuclear powerplant without first getting approval from the State and County governments](https://www.bloomberg.com/news/articles/2019-05-15/disney-world-s-literal-nuclear-option-explained).  

## Anyone can be a semi-anonymous land owner  

Disney's shell game is by no means unique. In fact, incredibly common to own land indirectly through a semi-anonymous or anonymous legal entity like a corporation and nearly anyone can do it. Incorporating a business in Florida is extremely easy, and requires only three things: around $200 in spare cash, a template for the new companies articles of incorporation, and less than 10 minutes of time at sunbiz.com filling out the forms from home.  

There are numerous reasons - legal, tax, nefarious, and other - that big players purchase and own land through proxies.  
  
Regardless of *why* someone owns land via a proxy corporation, however, the practice ultimately serves to obscure the true social, political, and economic power wielded by large land owners.

Unlike public companies traded on the stock market, privately held companies are only required to report the barest minimum of data to the government - typically their articles of incorporation, a list of board members, and designated agent. For these reasons, the public record related to corporate ownership is virtually useless if you want to actually unravel who actually owns the 8.5+ million parcels in the State of Florida. 

Property ownership, however, is heavily a heavily legislated and regulated affair. State and county governments typically require a property owner to register an actual address where they can be reached by mail so the property owner can be contacted in the event a legal or tax dispute arises. Put another way, with $200 dollars and a a few minutes of time, anyone can obfuscate the *name* of who owns a property. All it takes is incorporating a pivate company and registering the parcel under this assumed business name. What you cannot do is obscure is the physical address where the actual owner is nominally "located" and can be reached via registered mail.  
  
The requirement to provide a physical address where the owner can be reached provides a crack in the wall of anonymity of land owners that can be exploited.  
  
## Developing Rhizomatic Methods  
> Unlike trees or their roots, the rhizome connects any point to any other point.. its traits are not necessarily linked to traits of the same nature.  
> - Deleuze and Guattari, *A Thousand Plateaus: Capitalism and Schizophrenia* (1987)  

Deleuze and Guattari, in their sprawling philosophical masterpiece that is a grand tour all human knowledge through the ages (or irredemable piece of jumbled postmodern trash, depending on your point of view), delineated between *arboreal* and *rhizomatic* modes of knowledge. 
  
Arboreal - or treelike - knowledge is knowledge is the classic mode of western scientific thought. Think classic Linean biology, that is centered on the idea of the species and has a descending heirarchy of Kingdom, Order, Phylum, etc., all the way down to a species. 

Rhizomes, on the other hand, are also known as [creeping roots](https://en.wikipedia.org/wiki/Rhizome). They are fundamentally organized on a different principle than a tree. A rhizomes grow horizontally through the soil, adding more branches as they find nutrients. New growths are added in no predefined patter; rather the rhizome pseudorandomly grows as nutrients are found and the rhizome adds new sections. 

The arboreal approach is the classic method by which we structure GIS (and CS) problems: impose a data model, apply a classification system, and add levels and refinements as needed to both for the task at hand.  

For several reasons, the arboreal apprach is precisely the wrong approach to use when examining semi-anonymous land ownership:  

  1. Corporate reporting laws for private companies only require that the board of directors be recorded, not the owners.  
  2. The publicly available data on private companies is notoriously awful - sunbiz.com gives you the data as PDF copies of the articles of incorporation and a listiong for a registered agent (who can be a CPA or other functionary).  
  3. Companies incorporate under state governments, so for a truly exhaustive search, data from the other 49 states also needs munged into a common format.  
  4.  Parcel data is also notoriously bad, and the same companies are frequently registered under 'close but not exact' names, e.g. Northeast Development, LLC vs NE Development LLC.  
  

  



  


  

  

  

 

  

