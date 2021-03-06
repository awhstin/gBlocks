#pragma TextEncoding = "MacRoman"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function MakegHex(arraySize,hexSize,hexOpt,rowOpt,exclOpt)
	Variable arraySize,hexSize,hexOpt,rowOpt,exclOpt
	
	Variable axisSize = MakeArray(arraySize,hexSize,hexOpt,rowOpt,exclOpt)
	DisplayHexArray(arraySize,axisSize)
End

Function MakeTowerHex()
	Variable axisSize = MakeArray(50,1,0,0,1)
	DisplayTowerHex(50,axisSize)
End

// First part of this code is to make hexagonal array with centres as points in a 2D wave

///	@param	arraySize	size of square array (whole units)
///	@param	hexSize	size of hexagon (centre to any corner)
///	@param	hexOpt	pointy-topped/horizontal = 0, flat-topped/vertical = 1
///	@param	rowOpt	even r/q = 0, odd r/q = 1
///	@param	exclOpt	square array = 0, constrain to circle = 1
Function MakeArray(arraySize,hexSize,hexOpt,rowOpt,exclOpt)
	Variable arraySize,hexSize,hexOpt,rowOpt,exclOpt
	
	// sanity check
	if(arraySize < 5 || hexSize == 0)
		Abort "Use different parameters"
	endif
	
	Variable height = hexSize * 2
	Variable vert = height * (3/4)
	Variable width = sqrt(3)/2 * height
	Variable horiz = width
	Variable midPQ = (arraySize - 1) / 2
	Variable centX,centY // centre of array
	
	Make/O/N=(arraySize,arraySize) matX,matY
	
	if(hexOpt == 0)
		if(rowOpt == 0)
		// hexOpt = 0, rowOpt = 0
		// 0,0 is 1w,0.5h; 0,1 is 0.5w,1.25h
		// even-r horizontal
		matX = (1 * width) + (p * width) - (mod(q,2) * 0.5 * width)
		matY = (0.5 * height) + (q * vert)
		centX = (1 * width) + (midPQ * width) - (mod(midPQ,2) * 0.5 * width)
		centY = (0.5 * height) + (midPQ * vert)
		else
		// hexOpt = 0, rowOpt = 1
		// 0,0 is 0.5w,0.5h; 0,1 is 1w,1.25h
		// odd-r horizontal
		matX = (0.5 * width) + (p * width) + (mod(q,2) * 0.5 * width)
		matY = (0.5 * height) + (q * vert)
		centX = (0.5 * width) + (midPQ * width) + (mod(midPQ,2) * 0.5 * width)
		centY = (0.5 * height) + (midPQ * vert)
		endif
	else
		width = hexSize * 2
		horiz = width * (3/4)
		height = sqrt(3)/2 * width
		vert = height
		if(rowOpt == 0)
		// hexOpt = 1, rowOpt = 0
		// 0,0 is 0.5w,1h; 1,0 is 1.25w,0.5h
		// even-q vertical
		matX = (1.25 * width) + (p * width)
		matY = (0.5 * height) + (q * vert) - (mod(p,2) * 0.5 * height)
		centX = (1.25 * width) + (midPQ * width)
		centY = (0.5 * height) + (midPQ * vert) - (mod(midPQ,2) * 0.5 * height)
		else
		// hexOpt = 1, rowOpt = 1
		// 0,0 is 0.5w,0.5h; 1,0 is 1.25w,1h
		// odd-q vertical
		matX = (0.5 * width) + (p * width)
		matY = (0.5 * height) + (q * vert) + (mod(p,2) * 0.5 * height)
		centX = (0.5 * width) + (midPQ * width)
		centY = (0.5 * height) + (midPQ * vert) + (mod(midPQ,2) * 0.5 * height)
		endif
	endif
	
	Variable dist = min(centX,centY)
	// do exclusion
	if(exclOpt == 1)
		matX = (sqrt( (matX[p][q] - centX)^2 + (matY[p][q] - centY)^2) < dist ) ? matX[p][q] : NaN
		matY = (sqrt( (matX[p][q] - centX)^2 + (matY[p][q] - centY)^2) < dist ) ? matY[p][q] : NaN
	endif
	Concatenate/O/KILL {matx,matY}, matA
	Return max(centX,centY)
End

Function DisplayHexArray(arraySize,axisSize)
	Variable arraySize,axisSize
	
	WAVE/Z matA
	Redimension/E=1/N=(arraySize^2,2) matA
	// Add noise to coords
	matA += gnoise(0.1)
	
	KillWindow/Z result
	Display/N=result/W=(50,50,650,650) matA[][1] vs matA[][0]
	ModifyGraph/W=result margin=5,width={Plan,1,bottom,left}
	ModifyGraph/W=result mode=3,marker=19,mrkThick=0
	ModifyGraph/W=result noLabel=2,axThick=0,standoff=0
	SetAxis/W=result bottom 0,2*axisSize
	SetAxis/W=result left 0 - (10*(axisSize/arraySize)),2*axisSize - (10*(axisSize/arraySize))
	// make size
	Make/O/N=(arraySize^2) sizeW = 5 + enoise(5)
	ModifyGraph/W=result zmrkSize(matA)={sizeW,*,*,1,10}
	// make color
	Make/O/N=(arraySize^2,4) colorW=0
	colorW[][3] = 65535/2 + 65535*enoise(0.5)
	ModifyGraph/W=result zColor(matA)={colorW,*,*,directRGB,0}
	Make/FREE/N=(arraySize^2) redW = enoise(1) - 0.9
	Variable i
	
	for(i = 0; i < arraySize^2; i += 1)
		if(redW[i] > 0)
			colorW[i][0] = 65535
		endif
	endfor
End

Function DisplayTowerHex(arraySize,axisSize)
	Variable arraySize,axisSize
	
	WAVE/Z matA
	// Add noise to coords
	matA += gnoise(2)
	SidechainDist(matA)
	WAVE/Z distW
	
	// make 2 column
	Redimension/E=1/N=(arraySize^2,2) matA
	
	KillWindow/Z result
	Display/N=result/W=(50,50,650,650) matA[][1] vs matA[][0]
	ModifyGraph/W=result margin=5,width={Plan,1,bottom,left}
	ModifyGraph/W=result mode=3,marker=19,mrkThick=0
	ModifyGraph/W=result noLabel=2,axThick=0,standoff=0
	SetAxis/W=result bottom 0,2*axisSize
	SetAxis/W=result left 0 - (10*(axisSize/arraySize)),2*axisSize - (10*(axisSize/arraySize))

	ModifyGraph/W=result zmrkSize(matA)={distW,*,*,10,1}
	// make color
	Make/O/N=(arraySize^2,4) colorW=0
	colorW[][3] = 65535/2 + 65535*enoise(0.5)
	ModifyGraph/W=result zColor(matA)={colorW,*,*,directRGB,0}
	Make/FREE/N=(arraySize^2) redW = enoise(1) - 0.9
	Variable i
	
	for(i = 0; i < arraySize^2; i += 1)
		if(redW[i] > 0)
			colorW[i][0] = 65535
		endif
	endfor
End

Function SidechainDist(matA)
	Wave matA
	Variable pVar = dimsize(matA,0)
	Variable qVar = dimsize(matA,1)
	
	Make/O/N=(pVar,qVar) distW=0
	
	Variable i,j
	
	for(i = 0; i < pVar; i += 1)
		for(j = 0; j < qVar; j += 1)
			Make/FREE/N=(6) w0
			if(i == 0 || j == 0 || i == pvar - 1 || j == pvar -1)
				w0 = 0
			else
			w0[0] = sqrt( (matA[i][j][0] - matA[i-1][j-1][0])^2 + (matA[i][j][1] - matA[i-1][j-1][1])^2 ) //1 11 oclock
			w0[1] = sqrt( (matA[i][j][0] - matA[i][j-1][0])^2 + (matA[i][j][1] - matA[i][j-1][1])^2 ) //2 1 oclock
			w0[2] = sqrt( (matA[i][j][0] - matA[i-1][j][0])^2 + (matA[i][j][1] - matA[i-1][j][1])^2 ) //3 9 oclock
			w0[3] = sqrt( (matA[i][j][0] - matA[i+1][j][0])^2 + (matA[i][j][1] - matA[i+1][j][1])^2 ) //4 3 oclock
			w0[4] = sqrt( (matA[i][j][0] - matA[i-1][j+1][0])^2 + (matA[i][j][1] - matA[i-1][j+1][1])^2 ) //5 7 oclock
			w0[5] = sqrt( (matA[i][j][0] - matA[i][j+1][0])^2 + (matA[i][j][1] - matA[i][j+1][1])^2 ) //6 5 oclock
			endif
			WaveTransform zapnans,w0
			distW[i][j] = sum(w0) / numpnts(w0)
		endfor
	endfor
	Redimension/N=(pVar*qVar) distW
End