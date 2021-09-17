#=
    
    - This is a collection of helper functions written in Julia for The MRI Toolbox

    Input and Output Parameters for Code

    implimented within a Julia script or in REPL
    > include('./utils.jl')

    References:
    1. R. D. Dortch, J. Moore, K. Li, M. Jankiewicz, D. F. Gochberg, J. A. Hirtle, J. C. Gore, S. A. Smith, Quantitative magnetization transfer imaging of human brain at 7T. Neuroimage. 64, 640–649 (2013).
    2. F. Bagnato, G. Franco, F. Ye, R. Fan, P. Commiskey, S. A. Smith, J. Xu, R. Dortch, Selective inversion recovery quantitative magnetization transfer imaging: Toward a 3 T clinical application in multiple sclerosis. Mult. Scler. J. 26, 457–467 (2020).
    3. R. D. Dortch, F. Bagnato, D. F. Gochberg, J. C. Gore, S. A. Smith, Optimization of selective inversion recovery magnetization transfer imaging for macromolecular content mapping in the human brain. Magn. Reson. Med. 80, 1824–1835 (2018).
    4. R. D. Dortch, K. Li, D. F. Gochberg, E. B. Welch, A. N. Dula, A. A. Tamhane, J. C. Gore, S. A. Smith, Quantitative magnetization transfer imaging in human brain at 3 T via selective inversion recovery. Magn. Reson. Med. 66, 1346–1352 (2011).

=#

function nlsfit(f::Function, xvalues,yvalues,guesses::Vector{T}) where T
    # f(xvalues,guesses)
    # yvalues
    
    # fit = curve_fit(f,xvalues,yvalues,guesses;autodiff=:finiteforward)
    fit = curve_fit(f,xvalues,yvalues,guesses;autodiff=:forwarddiff)
    # return fit.param
    oftype(guesses,fit.param)
end

function SIR_Mz0(x::Matrix{Float64}, p::Vector{N}, kmf::Float64; 
    Sm::Float64=0.83, R1m::Float64=NaN, mag::Bool=true)::Vector{N} where {N} # N = parameters

    # Extract ti and td values from x
    @views ti = x[:,1]
    @views td = x[:,2]

    # Define model parameters based on p
    pmf = p[1]
    R1f = p[2]
    Sf  = p[3]
    Mf∞ = p[4]

    # Define R1m based on user-defined value (=R1f when set to NaN)
    if isnan(R1m)
        R1m = R1f
    end

    # Define kfm based on kmf and pmf (assuming mass balance)
    kfm = kmf*pmf

    # Apparent rate constants
    ΔR1 = sqrt((R1f-R1m+kfm-kmf)^2.0 + 4.0*kfm*kmf)
    R1⁺ = (R1f + R1m + kfm + kmf + ΔR1) / 2.0
    R1⁻ = R1⁺ - ΔR1

    # Component amplitudes for td terms
    bf_td⁺ = -(R1f - R1⁻) / ΔR1
    bf_td⁻ =  (R1f - R1⁺) / ΔR1
    bm_td⁺ = -(R1m - R1⁻) / ΔR1
    bm_td⁻ =  (R1m - R1⁺) / ΔR1

    # Loop over ti/td values
    # make this a new function
    M = similar(ti,N) #<- this is allocating a lot of memory
    # M = similar(ti,N,0)
    for k ∈ eachindex(td) #slower with simd

        # Signal recovery during td
        E_td⁺ = exp(-R1⁺*td[k])
        E_td⁻ = exp(-R1⁻*td[k])
        Mf_td = bf_td⁺*E_td⁺ + bf_td⁻*E_td⁻ + 1.0
        Mm_td = bm_td⁺*E_td⁺ + bm_td⁻*E_td⁻ + 1.0

        # Component amplitude terms for ti terms
        a = Sf*Mf_td - 1.0
        b = (Sf*Mf_td - Sm*Mm_td) * kfm
        bf_ti⁺ =  (a*(R1f-R1⁻) + b) / ΔR1
        bf_ti⁻ = -(a*(R1f-R1⁺) + b) / ΔR1

        # Signal recovery during ti
        M[k] = (bf_ti⁺*exp(-R1⁺*ti[k]) + bf_ti⁻*exp(-R1⁻*ti[k]) + 1.0) * Mf∞
        # push!(M,(bf_ti⁺*exp(-R1⁺*ti[k]) + bf_ti⁻*exp(-R1⁻*ti[k]) + 1.0) * Mf∞)

        # Take the magnitude of the signal
        if mag
            M[k] = abs(M[k])
        end
    end

    # Return signal
    return M
end