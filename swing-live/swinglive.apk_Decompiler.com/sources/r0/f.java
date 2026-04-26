package R0;

import Y0.s;
import com.google.crypto.tink.shaded.protobuf.AbstractC0296a;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0316v;
import com.google.crypto.tink.shaded.protobuf.B;
import com.google.crypto.tink.shaded.protobuf.C0302g;
import com.google.crypto.tink.shaded.protobuf.C0306k;
import d1.W;
import d1.X;
import d1.Y;
import d1.b0;
import d1.d0;
import d1.e0;
import d1.f0;
import d1.g0;
import d1.r0;
import java.io.IOException;
import java.security.GeneralSecurityException;
import java.util.Collections;
import java.util.Iterator;
import java.util.Map;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class f {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final f f1683c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final f f1684d;
    public static final f e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f1685a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f1686b;

    static {
        int i4 = 0;
        f1683c = new f("ENABLED", i4);
        f1684d = new f("DISABLED", i4);
        e = new f("DESTROYED", i4);
    }

    public /* synthetic */ f(Object obj, int i4) {
        this.f1685a = i4;
        this.f1686b = obj;
    }

    public synchronized void a(b0 b0Var) {
        f0 f0VarB;
        synchronized (this) {
            f0VarB = b(o.e(b0Var), b0Var.A());
        }
        d0 d0Var = (d0) this.f1686b;
        d0Var.e();
        g0.x((g0) d0Var.f3838b, f0VarB);
    }

    public synchronized f0 b(Y y4, r0 r0Var) {
        int iA;
        synchronized (this) {
            iA = s.a();
            while (d(iA)) {
                iA = s.a();
            }
        }
        return (f0) e0VarF.b();
        if (r0Var == r0.UNKNOWN_PREFIX) {
            throw new GeneralSecurityException("unknown output prefix type");
        }
        e0 e0VarF = f0.F();
        e0VarF.e();
        f0.w((f0) e0VarF.f3838b, y4);
        e0VarF.e();
        f0.z((f0) e0VarF.f3838b, iA);
        e0VarF.e();
        f0.y((f0) e0VarF.f3838b);
        e0VarF.e();
        f0.x((f0) e0VarF.f3838b, r0Var);
        return (f0) e0VarF.b();
    }

    public synchronized C0747k c() {
        return C0747k.D((g0) ((d0) this.f1686b).b());
    }

    public synchronized boolean d(int i4) {
        Iterator it = Collections.unmodifiableList(((g0) ((d0) this.f1686b).f3838b).A()).iterator();
        while (it.hasNext()) {
            if (((f0) it.next()).B() == i4) {
                return true;
            }
        }
        return false;
    }

    public Y e(AbstractC0303h abstractC0303h) throws GeneralSecurityException {
        Y0.d dVar = (Y0.d) this.f1686b;
        try {
            Q.b bVarN = dVar.n();
            AbstractC0296a abstractC0296aI = bVarN.i(abstractC0303h);
            bVarN.j(abstractC0296aI);
            AbstractC0296a abstractC0296aA = bVarN.a(abstractC0296aI);
            W wD = Y.D();
            String strL = dVar.l();
            wD.e();
            Y.w((Y) wD.f3838b, strL);
            try {
                int iB = ((AbstractC0316v) abstractC0296aA).b(null);
                byte[] bArr = new byte[iB];
                C0306k c0306k = new C0306k(bArr, iB);
                abstractC0296aA.f(c0306k);
                if (c0306k.f3814k - c0306k.f3815l != 0) {
                    throw new IllegalStateException("Did not write as much data as expected.");
                }
                C0302g c0302g = new C0302g(bArr);
                wD.e();
                Y.x((Y) wD.f3838b, c0302g);
                X xO = dVar.o();
                wD.e();
                Y.y((Y) wD.f3838b, xO);
                return (Y) wD.b();
            } catch (IOException e4) {
                throw new RuntimeException(abstractC0296aA.c("ByteString"), e4);
            }
        } catch (B e5) {
            throw new GeneralSecurityException("Unexpected proto", e5);
        }
    }

    public String toString() {
        switch (this.f1685a) {
            case 0:
                return (String) this.f1686b;
            default:
                return super.toString();
        }
    }

    public f(Y0.d dVar, Class cls) {
        this.f1685a = 2;
        if (((Map) dVar.f2472c).keySet().contains(cls) || Void.class.equals(cls)) {
            this.f1686b = dVar;
            return;
        }
        throw new IllegalArgumentException("Given internalKeyMananger " + dVar.toString() + " does not support primitive class " + cls.getName());
    }
}
