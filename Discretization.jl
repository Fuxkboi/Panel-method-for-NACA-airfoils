begin
	using Plots
	using DelimitedFiles
	using Luxor
end

begin
	#PARAMETERS: ANGLE OF ATTACK (DEGREES) AND FREESTREAM VELOCITY.
	uInfinity = 1;
	angleOfAttack = 5;
	#Reads data and plots the respective hydrofoil.
	hydrofoilData = readdlm("n2412.dat", Float64);
	xHydrofoil = hydrofoilData[:, 1];
	yHydrofoil = hydrofoilData[:, 2];
	P1 = plot(xHydrofoil, yHydrofoil,
		aspect_ratio = :equal,
		color = :black,
		linewidth = 2,
		label = :false,
		xlim = (-0.2, 1.2),
		ylim = (-0.2, 0.2),
		size = (1080, 720))
end

begin
	#Divides of the hydrofoil in N linear segments.
	function createPanels(xData, yData, N)
		R = (maximum(xData) - minimum(xData))/2;
		C = (maximum(xData) + minimum(xData))/2;
		θ = LinRange(0, 2pi, N + 1);
		#Coordinates of panel edges.
		xPanel = C .+ R.*cos.(θ);
		yPanel = zeros(length(xPanel));
		#Coordinates of panel midpoints.
		xM = zeros(length(xPanel) - 1);
		yM = zeros(length(yPanel) - 1);
		#Angles between vectors normal to panels and the positive x-axis.
		φ = zeros(length(xPanel) - 1);
		#Angles between vectors tangent to panels and the positive x-axis.
		ω = zeros(length(xPanel) - 1);
		#Length of panels.
		L = zeros(length(xPanel) - 1);
		counter = 1;
		nudge = 10^(-15);
		#Loop checks where a panel edge is located in reference to xData points and uses linear interpolation to calculate the respective ordinate.
		for i in 1:(length(xPanel) - 1)
			while counter < length(xData) - 1
				if (xData[counter] - nudge < xPanel[i] < xData[counter + 1] + nudge) || (xData[counter + 1] - nudge < xPanel[i] < xData[counter] + nudge)
					break
				else
					counter = counter + 1;
				end
			end
			m = (yData[counter + 1] - yData[counter])/(xData[counter + 1] - xData[counter]);
			n = (xData[counter]*yData[counter + 1] - xData[counter + 1]*yData[counter])/(xData[counter + 1] - xData[counter]);
			yPanel[i] = m*xPanel[i] - n;
		end
		#Loop utilizes simple linear algebra equations to compute the panel midpoints coordinates and angles between the panels and the positive x-axis.
		for i in 1:(length(xPanel) - 1)
			xM[i] = (xPanel[i + 1] + xPanel[i])/2;
			yM[i] = (yPanel[i + 1] + yPanel[i])/2;
			L[i] = sqrt((xPanel[i + 1] - xPanel[i])^2 + (yPanel[i + 1] - yPanel[i])^2)
			ω[i] = atan((yPanel[i + 1] - yPanel[i]), (xPanel[i + 1] - xPanel[i]));
			φ[i] = ω[i] - pi/2;
		end
		return xPanel, yPanel, xM, yM, ω, φ, L
	end
	#Plots the outputs of the function defined above.
	xPanel, yPanel, xM, yM, ω, φ, L = createPanels(xHydrofoil, yHydrofoil, 100);
	P2 = plot(xPanel, yPanel,
		aspect_ratio = :equal,
		color = :black,
		label = "Edges of panels",
		xlim = (-0.2, 1.2),
		ylim = (-0.2, 0.2),
		marker = :circle, 
		markersize = 5,
		size = (1080, 720))
	P2 = scatter!(xM, yM,
		color = :red,
		marker = :circle,
		markersize = 3,
		label = "Midpoints of panels")
	P2 = quiver!(xM, yM, quiver = 0.05.*(cos.(φ), sin.(φ)),
		color = :red,
		marker = :none)
end 
