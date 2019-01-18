library(shiny)
genelist<-read.table("UniProt.txt",header=T)
ui <- 
  fluidPage(
	h3(
		div(style="display:inline-block;",img(src="mutplot.2.png",height=150,width=700,style="left;")),
		div(id="title","mutplot")
	),
	sidebarLayout(
		sidebarPanel(
			fileInput("file1","Select File",accept=c("text","csv",".txt",".csv")),
			checkboxInput("header","Header",TRUE),
			radioButtons("sep","Separator",c(Tab="\t",Comma=",")),
			#radioButtons("gene","Gene",c("AR"="AR","BRCA1"='BRCA1',TP53="TP53"),inline=T)
			selectInput("gene","Gene",genelist[,1],selectize=FALSE),
			selectInput("AAfreq","Amino acid frequency threshold for highlight",c("Frequency",1:4,seq(5,30,by=5))),
			selectInput("plotformat","Image file figure format",c("format","jpeg","pdf","png","svg")),
			#actionButton("plot","Plot"),
			downloadButton("downloadplot","Download Plot"),
			downloadButton("downloaddata","Download Data"),
			downloadButton("downloaddomain","Download Domain")
		),
		mainPanel(
		h4("An example for the selected file:"),
		tableOutput("freq")
		#plotOutput("plot")
		)
 	)
  )