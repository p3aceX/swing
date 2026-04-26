package R0;

import d1.Z;
import d1.f0;
import d1.g0;
import d1.h0;
import d1.i0;
import d1.j0;
import d1.k0;
import d1.r0;
import java.nio.charset.Charset;

/* JADX INFO: loaded from: classes.dex */
public abstract class p {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final /* synthetic */ int f1707a = 0;

    static {
        Charset.forName("UTF-8");
    }

    public static k0 a(g0 g0Var) {
        h0 h0VarZ = k0.z();
        int iB = g0Var.B();
        h0VarZ.e();
        k0.w((k0) h0VarZ.f3838b, iB);
        for (f0 f0Var : g0Var.A()) {
            i0 i0VarB = j0.B();
            String strB = f0Var.A().B();
            i0VarB.e();
            j0.w((j0) i0VarB.f3838b, strB);
            Z zD = f0Var.D();
            i0VarB.e();
            j0.y((j0) i0VarB.f3838b, zD);
            r0 r0VarC = f0Var.C();
            i0VarB.e();
            j0.x((j0) i0VarB.f3838b, r0VarC);
            int iB2 = f0Var.B();
            i0VarB.e();
            j0.z((j0) i0VarB.f3838b, iB2);
            j0 j0Var = (j0) i0VarB.b();
            h0VarZ.e();
            k0.x((k0) h0VarZ.f3838b, j0Var);
        }
        return (k0) h0VarZ.b();
    }
}
