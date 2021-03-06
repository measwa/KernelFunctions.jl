@testset "zygote_adjoints" begin
    rng = MersenneTwister(123456)
    x = rand(rng, 5)
    y = rand(rng, 5)
    r = rand(rng, 5)
    Q = Matrix(Cholesky(rand(rng, 5, 5), 'U', 0))
    @assert isposdef(Q)

    gzeucl = gradient(:Zygote, [x, y]) do xy
        evaluate(Euclidean(), xy[1], xy[2])
    end
    gzsqeucl = gradient(:Zygote, [x, y]) do xy
        evaluate(SqEuclidean(), xy[1], xy[2])
    end
    gzdotprod = gradient(:Zygote, [x, y]) do xy
        evaluate(KernelFunctions.DotProduct(), xy[1], xy[2])
    end
    gzdelta = gradient(:Zygote, [x, y]) do xy
        evaluate(KernelFunctions.Delta(), xy[1], xy[2])
    end
    gzsinus = gradient(:Zygote, [x, y]) do xy
        evaluate(KernelFunctions.Sinus(r), xy[1], xy[2])
    end
    gzsqmaha = gradient(:Zygote, [Q, x, y]) do xy
        evaluate(SqMahalanobis(xy[1]), xy[2], xy[3])
    end

    gfeucl = gradient(:FiniteDiff, [x, y]) do xy
        evaluate(Euclidean(), xy[1], xy[2])
    end
    gfsqeucl = gradient(:FiniteDiff, [x, y]) do xy
        evaluate(SqEuclidean(), xy[1], xy[2])
    end
    gfdotprod = gradient(:FiniteDiff, [x, y]) do xy
        evaluate(KernelFunctions.DotProduct(), xy[1], xy[2])
    end
    gfdelta = gradient(:FiniteDiff, [x, y]) do xy
        evaluate(KernelFunctions.Delta(), xy[1], xy[2])
    end
    gfsinus = gradient(:FiniteDiff, [x, y]) do xy
        evaluate(KernelFunctions.Sinus(r), xy[1], xy[2])
    end
    gfsqmaha = gradient(:FiniteDiff, [Q, x, y]) do xy
        evaluate(SqMahalanobis(xy[1]), xy[2], xy[3])
    end

    @test all(gzeucl .≈ gfeucl)
    @test all(gzsqeucl .≈ gfsqeucl)
    @test all(gzdotprod .≈ gfdotprod)
    @test all(gzdelta .≈ gfdelta)
    @test all(gzsinus .≈ gfsinus)
    @test all(gzsqmaha .≈ gfsqmaha)
end
