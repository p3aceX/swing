package androidx.datastore.preferences.protobuf;

import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.google.crypto.tink.shaded.protobuf.AbstractC0299d;
import com.google.crypto.tink.shaded.protobuf.AbstractC0303h;
import com.google.crypto.tink.shaded.protobuf.AbstractC0307l;
import com.google.crypto.tink.shaded.protobuf.AbstractC0317w;
import com.google.crypto.tink.shaded.protobuf.AbstractC0320z;
import com.google.crypto.tink.shaded.protobuf.C0309n;
import java.nio.charset.Charset;
import java.util.List;

/* JADX INFO: renamed from: androidx.datastore.preferences.protobuf.j, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0199j {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f2994b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public int f2995c;
    public final Object e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f2993a = 0;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f2996d = 0;

    public C0199j(T0.d dVar) {
        Charset charset = AbstractC0211w.f3035a;
        this.e = dVar;
        dVar.f1873b = this;
    }

    public static void R(int i4) throws com.google.crypto.tink.shaded.protobuf.B {
        if ((i4 & 3) != 0) {
            throw com.google.crypto.tink.shaded.protobuf.B.f();
        }
    }

    public static void S(int i4) throws com.google.crypto.tink.shaded.protobuf.B {
        if ((i4 & 7) != 0) {
            throw com.google.crypto.tink.shaded.protobuf.B.f();
        }
    }

    public void A(InterfaceC0210v interfaceC0210v) throws C0213y {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 2) {
            int iD = dVar.D();
            if ((iD & 3) != 0) {
                throw new C0213y("Failed to parse the message.");
            }
            int iF = dVar.f() + iD;
            do {
                ((S) interfaceC0210v).add(Integer.valueOf(dVar.w()));
            } while (dVar.f() < iF);
            return;
        }
        if (i4 != 5) {
            throw C0213y.b();
        }
        do {
            ((S) interfaceC0210v).add(Integer.valueOf(dVar.w()));
            if (dVar.g()) {
                return;
            } else {
                iC = dVar.C();
            }
        } while (iC == this.f2994b);
        this.f2996d = iC;
    }

    public void B(List list) throws com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof AbstractC0317w;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 2) {
                int iD = dVar.D();
                R(iD);
                int iF = dVar.f() + iD;
                do {
                    list.add(Integer.valueOf(dVar.w()));
                } while (dVar.f() < iF);
                return;
            }
            if (i4 != 5) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            do {
                list.add(Integer.valueOf(dVar.w()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        AbstractC0317w abstractC0317w = (AbstractC0317w) list;
        int i5 = this.f2994b & 7;
        if (i5 == 2) {
            int iD2 = dVar.D();
            R(iD2);
            int iF2 = dVar.f() + iD2;
            do {
                abstractC0317w.g(dVar.w());
            } while (dVar.f() < iF2);
            return;
        }
        if (i5 != 5) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        do {
            abstractC0317w.g(dVar.w());
            if (dVar.g()) {
                return;
            } else {
                iC2 = dVar.C();
            }
        } while (iC2 == this.f2994b);
        this.f2996d = iC2;
    }

    public void C(InterfaceC0210v interfaceC0210v) throws C0213y {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 1) {
            do {
                ((S) interfaceC0210v).add(Long.valueOf(dVar.x()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iD = dVar.D();
        if ((iD & 7) != 0) {
            throw new C0213y("Failed to parse the message.");
        }
        int iF = dVar.f() + iD;
        do {
            ((S) interfaceC0210v).add(Long.valueOf(dVar.x()));
        } while (dVar.f() < iF);
    }

    public void D(List list) throws com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof com.google.crypto.tink.shaded.protobuf.I;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 1) {
                do {
                    list.add(Long.valueOf(dVar.x()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iD = dVar.D();
            S(iD);
            int iF = dVar.f() + iD;
            do {
                list.add(Long.valueOf(dVar.x()));
            } while (dVar.f() < iF);
            return;
        }
        com.google.crypto.tink.shaded.protobuf.I i5 = (com.google.crypto.tink.shaded.protobuf.I) list;
        int i6 = this.f2994b & 7;
        if (i6 == 1) {
            do {
                i5.g(dVar.x());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i6 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iD2 = dVar.D();
        S(iD2);
        int iF2 = dVar.f() + iD2;
        do {
            i5.g(dVar.x());
        } while (dVar.f() < iF2);
    }

    public void E(InterfaceC0210v interfaceC0210v) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 0) {
            do {
                ((S) interfaceC0210v).add(Integer.valueOf(dVar.y()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iF = dVar.f() + dVar.D();
        do {
            ((S) interfaceC0210v).add(Integer.valueOf(dVar.y()));
        } while (dVar.f() < iF);
        O(iF);
    }

    public void F(List list) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof AbstractC0317w;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 0) {
                do {
                    list.add(Integer.valueOf(dVar.y()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iF = dVar.f() + dVar.D();
            do {
                list.add(Integer.valueOf(dVar.y()));
            } while (dVar.f() < iF);
            O(iF);
            return;
        }
        AbstractC0317w abstractC0317w = (AbstractC0317w) list;
        int i5 = this.f2994b & 7;
        if (i5 == 0) {
            do {
                abstractC0317w.g(dVar.y());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i5 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iF2 = dVar.f() + dVar.D();
        do {
            abstractC0317w.g(dVar.y());
        } while (dVar.f() < iF2);
        O(iF2);
    }

    public void G(InterfaceC0210v interfaceC0210v) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 0) {
            do {
                ((S) interfaceC0210v).add(Long.valueOf(dVar.z()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iF = dVar.f() + dVar.D();
        do {
            ((S) interfaceC0210v).add(Long.valueOf(dVar.z()));
        } while (dVar.f() < iF);
        O(iF);
    }

    public void H(List list) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof com.google.crypto.tink.shaded.protobuf.I;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 0) {
                do {
                    list.add(Long.valueOf(dVar.z()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iF = dVar.f() + dVar.D();
            do {
                list.add(Long.valueOf(dVar.z()));
            } while (dVar.f() < iF);
            O(iF);
            return;
        }
        com.google.crypto.tink.shaded.protobuf.I i5 = (com.google.crypto.tink.shaded.protobuf.I) list;
        int i6 = this.f2994b & 7;
        if (i6 == 0) {
            do {
                i5.g(dVar.z());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i6 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iF2 = dVar.f() + dVar.D();
        do {
            i5.g(dVar.z());
        } while (dVar.f() < iF2);
        O(iF2);
    }

    public void I(InterfaceC0210v interfaceC0210v, boolean z4) throws com.google.crypto.tink.shaded.protobuf.A, C0212x {
        String strA;
        int iC;
        if ((this.f2994b & 7) != 2) {
            throw C0213y.b();
        }
        do {
            T0.d dVar = (T0.d) this.e;
            if (z4) {
                P(2);
                strA = dVar.B();
            } else {
                P(2);
                strA = dVar.A();
            }
            ((S) interfaceC0210v).add(strA);
            if (dVar.g()) {
                return;
            } else {
                iC = dVar.C();
            }
        } while (iC == this.f2994b);
        this.f2996d = iC;
    }

    public void J(List list, boolean z4) throws com.google.crypto.tink.shaded.protobuf.A, C0212x {
        String strA;
        int iC;
        int iC2;
        if ((this.f2994b & 7) != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        boolean z5 = list instanceof com.google.crypto.tink.shaded.protobuf.E;
        T0.d dVar = (T0.d) this.e;
        if (z5 && !z4) {
            com.google.crypto.tink.shaded.protobuf.E e = (com.google.crypto.tink.shaded.protobuf.E) list;
            do {
                e.e(i());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        do {
            if (z4) {
                P(2);
                strA = dVar.B();
            } else {
                P(2);
                strA = dVar.A();
            }
            list.add(strA);
            if (dVar.g()) {
                return;
            } else {
                iC = dVar.C();
            }
        } while (iC == this.f2994b);
        this.f2996d = iC;
    }

    public void K(InterfaceC0210v interfaceC0210v) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 0) {
            do {
                ((S) interfaceC0210v).add(Integer.valueOf(dVar.D()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iF = dVar.f() + dVar.D();
        do {
            ((S) interfaceC0210v).add(Integer.valueOf(dVar.D()));
        } while (dVar.f() < iF);
        O(iF);
    }

    public void L(List list) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof AbstractC0317w;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 0) {
                do {
                    list.add(Integer.valueOf(dVar.D()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iF = dVar.f() + dVar.D();
            do {
                list.add(Integer.valueOf(dVar.D()));
            } while (dVar.f() < iF);
            O(iF);
            return;
        }
        AbstractC0317w abstractC0317w = (AbstractC0317w) list;
        int i5 = this.f2994b & 7;
        if (i5 == 0) {
            do {
                abstractC0317w.g(dVar.D());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i5 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iF2 = dVar.f() + dVar.D();
        do {
            abstractC0317w.g(dVar.D());
        } while (dVar.f() < iF2);
        O(iF2);
    }

    public void M(InterfaceC0210v interfaceC0210v) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 0) {
            do {
                ((S) interfaceC0210v).add(Long.valueOf(dVar.E()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iF = dVar.f() + dVar.D();
        do {
            ((S) interfaceC0210v).add(Long.valueOf(dVar.E()));
        } while (dVar.f() < iF);
        O(iF);
    }

    public void N(List list) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof com.google.crypto.tink.shaded.protobuf.I;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 0) {
                do {
                    list.add(Long.valueOf(dVar.E()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iF = dVar.f() + dVar.D();
            do {
                list.add(Long.valueOf(dVar.E()));
            } while (dVar.f() < iF);
            O(iF);
            return;
        }
        com.google.crypto.tink.shaded.protobuf.I i5 = (com.google.crypto.tink.shaded.protobuf.I) list;
        int i6 = this.f2994b & 7;
        if (i6 == 0) {
            do {
                i5.g(dVar.E());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i6 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iF2 = dVar.f() + dVar.D();
        do {
            i5.g(dVar.E());
        } while (dVar.f() < iF2);
        O(iF2);
    }

    public final void O(int i4) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        switch (this.f2993a) {
            case 0:
                if (((T0.d) this.e).f() != i4) {
                    throw C0213y.e();
                }
                return;
            default:
                if (((T0.d) this.e).f() != i4) {
                    throw com.google.crypto.tink.shaded.protobuf.B.g();
                }
                return;
        }
    }

    public final void P(int i4) throws com.google.crypto.tink.shaded.protobuf.A, C0212x {
        switch (this.f2993a) {
            case 0:
                if ((this.f2994b & 7) != i4) {
                    throw C0213y.b();
                }
                return;
            default:
                if ((this.f2994b & 7) != i4) {
                    throw com.google.crypto.tink.shaded.protobuf.B.c();
                }
                return;
        }
    }

    public boolean Q() {
        int i4;
        T0.d dVar = (T0.d) this.e;
        if (dVar.g() || (i4 = this.f2994b) == this.f2995c) {
            return false;
        }
        return dVar.F(i4);
    }

    public final int a() {
        switch (this.f2993a) {
            case 0:
                int i4 = this.f2996d;
                if (i4 != 0) {
                    this.f2994b = i4;
                    this.f2996d = 0;
                } else {
                    this.f2994b = ((T0.d) this.e).C();
                }
                int i5 = this.f2994b;
                return (i5 == 0 || i5 == this.f2995c) ? com.google.android.gms.common.api.f.API_PRIORITY_OTHER : i5 >>> 3;
            default:
                int i6 = this.f2996d;
                if (i6 != 0) {
                    this.f2994b = i6;
                    this.f2996d = 0;
                } else {
                    this.f2994b = ((T0.d) this.e).C();
                }
                int i7 = this.f2994b;
                return (i7 == 0 || i7 == this.f2995c) ? com.google.android.gms.common.api.f.API_PRIORITY_OTHER : i7 >>> 3;
        }
    }

    public void b(Object obj, U u4, C0202m c0202m) {
        int i4 = this.f2995c;
        this.f2995c = ((this.f2994b >>> 3) << 3) | 4;
        try {
            u4.f(obj, this, c0202m);
            if (this.f2994b == this.f2995c) {
            } else {
                throw new C0213y("Failed to parse the message.");
            }
        } finally {
            this.f2995c = i4;
        }
    }

    public void c(Object obj, com.google.crypto.tink.shaded.protobuf.c0 c0Var, C0309n c0309n) {
        int i4 = this.f2995c;
        this.f2995c = ((this.f2994b >>> 3) << 3) | 4;
        try {
            c0Var.j(obj, this, c0309n);
            if (this.f2994b == this.f2995c) {
            } else {
                throw com.google.crypto.tink.shaded.protobuf.B.f();
            }
        } finally {
            this.f2995c = i4;
        }
    }

    public void d(Object obj, U u4, C0202m c0202m) throws C0213y {
        T0.d dVar = (T0.d) this.e;
        int iD = dVar.D();
        if (dVar.f1872a >= 100) {
            throw new C0213y("Protocol message had too many levels of nesting.  May be malicious.  Use setRecursionLimit() to increase the recursion depth limit.");
        }
        int iL = dVar.l(iD);
        dVar.f1872a++;
        u4.f(obj, this, c0202m);
        dVar.b(0);
        dVar.f1872a--;
        dVar.j(iL);
    }

    public void e(Object obj, com.google.crypto.tink.shaded.protobuf.c0 c0Var, C0309n c0309n) throws com.google.crypto.tink.shaded.protobuf.B {
        T0.d dVar = (T0.d) this.e;
        int iD = dVar.D();
        if (dVar.f1872a >= 100) {
            throw new com.google.crypto.tink.shaded.protobuf.B("Protocol message had too many levels of nesting.  May be malicious.  Use CodedInputStream.setRecursionLimit() to increase the depth limit.");
        }
        int iL = dVar.l(iD);
        dVar.f1872a++;
        c0Var.j(obj, this, c0309n);
        dVar.b(0);
        dVar.f1872a--;
        dVar.j(iL);
    }

    public void f(InterfaceC0210v interfaceC0210v) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 0) {
            do {
                ((S) interfaceC0210v).add(Boolean.valueOf(dVar.m()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iF = dVar.f() + dVar.D();
        do {
            ((S) interfaceC0210v).add(Boolean.valueOf(dVar.m()));
        } while (dVar.f() < iF);
        O(iF);
    }

    public void g(List list) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof AbstractC0299d;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 0) {
                do {
                    list.add(Boolean.valueOf(dVar.m()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iF = dVar.f() + dVar.D();
            do {
                list.add(Boolean.valueOf(dVar.m()));
            } while (dVar.f() < iF);
            O(iF);
            return;
        }
        AbstractC0299d abstractC0299d = (AbstractC0299d) list;
        int i5 = this.f2994b & 7;
        if (i5 == 0) {
            do {
                abstractC0299d.g(dVar.m());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i5 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iF2 = dVar.f() + dVar.D();
        do {
            abstractC0299d.g(dVar.m());
        } while (dVar.f() < iF2);
        O(iF2);
    }

    public C0196g h() throws com.google.crypto.tink.shaded.protobuf.A, C0212x {
        P(2);
        return ((T0.d) this.e).n();
    }

    public AbstractC0303h i() throws com.google.crypto.tink.shaded.protobuf.A, C0212x {
        P(2);
        return ((T0.d) this.e).o();
    }

    public void j(InterfaceC0210v interfaceC0210v) throws C0212x {
        int iC;
        if ((this.f2994b & 7) != 2) {
            throw C0213y.b();
        }
        do {
            ((S) interfaceC0210v).add(h());
            T0.d dVar = (T0.d) this.e;
            if (dVar.g()) {
                return;
            } else {
                iC = dVar.C();
            }
        } while (iC == this.f2994b);
        this.f2996d = iC;
    }

    public void k(List list) throws com.google.crypto.tink.shaded.protobuf.A {
        int iC;
        if ((this.f2994b & 7) != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        do {
            list.add(i());
            T0.d dVar = (T0.d) this.e;
            if (dVar.g()) {
                return;
            } else {
                iC = dVar.C();
            }
        } while (iC == this.f2994b);
        this.f2996d = iC;
    }

    public void l(InterfaceC0210v interfaceC0210v) throws C0213y {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 1) {
            do {
                ((S) interfaceC0210v).add(Double.valueOf(dVar.p()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iD = dVar.D();
        if ((iD & 7) != 0) {
            throw new C0213y("Failed to parse the message.");
        }
        int iF = dVar.f() + iD;
        do {
            ((S) interfaceC0210v).add(Double.valueOf(dVar.p()));
        } while (dVar.f() < iF);
    }

    public void m(List list) throws com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof AbstractC0307l;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 1) {
                do {
                    list.add(Double.valueOf(dVar.p()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iD = dVar.D();
            S(iD);
            int iF = dVar.f() + iD;
            do {
                list.add(Double.valueOf(dVar.p()));
            } while (dVar.f() < iF);
            return;
        }
        AbstractC0307l abstractC0307l = (AbstractC0307l) list;
        int i5 = this.f2994b & 7;
        if (i5 == 1) {
            do {
                abstractC0307l.g(dVar.p());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i5 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iD2 = dVar.D();
        S(iD2);
        int iF2 = dVar.f() + iD2;
        do {
            abstractC0307l.g(dVar.p());
        } while (dVar.f() < iF2);
    }

    public void n(InterfaceC0210v interfaceC0210v) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 0) {
            do {
                ((S) interfaceC0210v).add(Integer.valueOf(dVar.q()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iF = dVar.f() + dVar.D();
        do {
            ((S) interfaceC0210v).add(Integer.valueOf(dVar.q()));
        } while (dVar.f() < iF);
        O(iF);
    }

    public void o(List list) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof AbstractC0317w;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 0) {
                do {
                    list.add(Integer.valueOf(dVar.q()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iF = dVar.f() + dVar.D();
            do {
                list.add(Integer.valueOf(dVar.q()));
            } while (dVar.f() < iF);
            O(iF);
            return;
        }
        AbstractC0317w abstractC0317w = (AbstractC0317w) list;
        int i5 = this.f2994b & 7;
        if (i5 == 0) {
            do {
                abstractC0317w.g(dVar.q());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i5 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iF2 = dVar.f() + dVar.D();
        do {
            abstractC0317w.g(dVar.q());
        } while (dVar.f() < iF2);
        O(iF2);
    }

    public Object p(p0 p0Var, Class cls, C0202m c0202m) throws C0213y, com.google.crypto.tink.shaded.protobuf.A {
        int iOrdinal = p0Var.ordinal();
        T0.d dVar = (T0.d) this.e;
        switch (iOrdinal) {
            case 0:
                P(1);
                return Double.valueOf(dVar.p());
            case 1:
                P(5);
                return Float.valueOf(dVar.t());
            case 2:
                P(0);
                return Long.valueOf(dVar.v());
            case 3:
                P(0);
                return Long.valueOf(dVar.E());
            case 4:
                P(0);
                return Integer.valueOf(dVar.u());
            case 5:
                P(1);
                return Long.valueOf(dVar.s());
            case K.k.STRING_SET_FIELD_NUMBER /* 6 */:
                P(5);
                return Integer.valueOf(dVar.r());
            case K.k.DOUBLE_FIELD_NUMBER /* 7 */:
                P(0);
                return Boolean.valueOf(dVar.m());
            case K.k.BYTES_FIELD_NUMBER /* 8 */:
                P(2);
                return dVar.B();
            case 9:
            default:
                throw new IllegalArgumentException("unsupported field type.");
            case 10:
                P(2);
                U uA = Q.f2927c.a(cls);
                AbstractC0209u abstractC0209uC = uA.c();
                d(abstractC0209uC, uA, c0202m);
                uA.d(abstractC0209uC);
                return abstractC0209uC;
            case ModuleDescriptor.MODULE_VERSION /* 11 */:
                return h();
            case 12:
                P(0);
                return Integer.valueOf(dVar.D());
            case 13:
                P(0);
                return Integer.valueOf(dVar.q());
            case 14:
                P(5);
                return Integer.valueOf(dVar.w());
            case 15:
                P(1);
                return Long.valueOf(dVar.x());
            case 16:
                P(0);
                return Integer.valueOf(dVar.y());
            case 17:
                P(0);
                return Long.valueOf(dVar.z());
        }
    }

    public void q(InterfaceC0210v interfaceC0210v) throws C0213y {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 2) {
            int iD = dVar.D();
            if ((iD & 3) != 0) {
                throw new C0213y("Failed to parse the message.");
            }
            int iF = dVar.f() + iD;
            do {
                ((S) interfaceC0210v).add(Integer.valueOf(dVar.r()));
            } while (dVar.f() < iF);
            return;
        }
        if (i4 != 5) {
            throw C0213y.b();
        }
        do {
            ((S) interfaceC0210v).add(Integer.valueOf(dVar.r()));
            if (dVar.g()) {
                return;
            } else {
                iC = dVar.C();
            }
        } while (iC == this.f2994b);
        this.f2996d = iC;
    }

    public void r(List list) throws com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof AbstractC0317w;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 2) {
                int iD = dVar.D();
                R(iD);
                int iF = dVar.f() + iD;
                do {
                    list.add(Integer.valueOf(dVar.r()));
                } while (dVar.f() < iF);
                return;
            }
            if (i4 != 5) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            do {
                list.add(Integer.valueOf(dVar.r()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        AbstractC0317w abstractC0317w = (AbstractC0317w) list;
        int i5 = this.f2994b & 7;
        if (i5 == 2) {
            int iD2 = dVar.D();
            R(iD2);
            int iF2 = dVar.f() + iD2;
            do {
                abstractC0317w.g(dVar.r());
            } while (dVar.f() < iF2);
            return;
        }
        if (i5 != 5) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        do {
            abstractC0317w.g(dVar.r());
            if (dVar.g()) {
                return;
            } else {
                iC2 = dVar.C();
            }
        } while (iC2 == this.f2994b);
        this.f2996d = iC2;
    }

    public void s(InterfaceC0210v interfaceC0210v) throws C0213y {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 1) {
            do {
                ((S) interfaceC0210v).add(Long.valueOf(dVar.s()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iD = dVar.D();
        if ((iD & 7) != 0) {
            throw new C0213y("Failed to parse the message.");
        }
        int iF = dVar.f() + iD;
        do {
            ((S) interfaceC0210v).add(Long.valueOf(dVar.s()));
        } while (dVar.f() < iF);
    }

    public void t(List list) throws com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof com.google.crypto.tink.shaded.protobuf.I;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 1) {
                do {
                    list.add(Long.valueOf(dVar.s()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iD = dVar.D();
            S(iD);
            int iF = dVar.f() + iD;
            do {
                list.add(Long.valueOf(dVar.s()));
            } while (dVar.f() < iF);
            return;
        }
        com.google.crypto.tink.shaded.protobuf.I i5 = (com.google.crypto.tink.shaded.protobuf.I) list;
        int i6 = this.f2994b & 7;
        if (i6 == 1) {
            do {
                i5.g(dVar.s());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i6 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iD2 = dVar.D();
        S(iD2);
        int iF2 = dVar.f() + iD2;
        do {
            i5.g(dVar.s());
        } while (dVar.f() < iF2);
    }

    public void u(InterfaceC0210v interfaceC0210v) throws C0213y {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 2) {
            int iD = dVar.D();
            if ((iD & 3) != 0) {
                throw new C0213y("Failed to parse the message.");
            }
            int iF = dVar.f() + iD;
            do {
                ((S) interfaceC0210v).add(Float.valueOf(dVar.t()));
            } while (dVar.f() < iF);
            return;
        }
        if (i4 != 5) {
            throw C0213y.b();
        }
        do {
            ((S) interfaceC0210v).add(Float.valueOf(dVar.t()));
            if (dVar.g()) {
                return;
            } else {
                iC = dVar.C();
            }
        } while (iC == this.f2994b);
        this.f2996d = iC;
    }

    public void v(List list) throws com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof com.google.crypto.tink.shaded.protobuf.r;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 2) {
                int iD = dVar.D();
                R(iD);
                int iF = dVar.f() + iD;
                do {
                    list.add(Float.valueOf(dVar.t()));
                } while (dVar.f() < iF);
                return;
            }
            if (i4 != 5) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            do {
                list.add(Float.valueOf(dVar.t()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        com.google.crypto.tink.shaded.protobuf.r rVar = (com.google.crypto.tink.shaded.protobuf.r) list;
        int i5 = this.f2994b & 7;
        if (i5 == 2) {
            int iD2 = dVar.D();
            R(iD2);
            int iF2 = dVar.f() + iD2;
            do {
                rVar.g(dVar.t());
            } while (dVar.f() < iF2);
            return;
        }
        if (i5 != 5) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        do {
            rVar.g(dVar.t());
            if (dVar.g()) {
                return;
            } else {
                iC2 = dVar.C();
            }
        } while (iC2 == this.f2994b);
        this.f2996d = iC2;
    }

    public void w(InterfaceC0210v interfaceC0210v) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 0) {
            do {
                ((S) interfaceC0210v).add(Integer.valueOf(dVar.u()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iF = dVar.f() + dVar.D();
        do {
            ((S) interfaceC0210v).add(Integer.valueOf(dVar.u()));
        } while (dVar.f() < iF);
        O(iF);
    }

    public void x(List list) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof AbstractC0317w;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 0) {
                do {
                    list.add(Integer.valueOf(dVar.u()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iF = dVar.f() + dVar.D();
            do {
                list.add(Integer.valueOf(dVar.u()));
            } while (dVar.f() < iF);
            O(iF);
            return;
        }
        AbstractC0317w abstractC0317w = (AbstractC0317w) list;
        int i5 = this.f2994b & 7;
        if (i5 == 0) {
            do {
                abstractC0317w.g(dVar.u());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i5 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iF2 = dVar.f() + dVar.D();
        do {
            abstractC0317w.g(dVar.u());
        } while (dVar.f() < iF2);
        O(iF2);
    }

    public void y(InterfaceC0210v interfaceC0210v) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int i4 = this.f2994b & 7;
        T0.d dVar = (T0.d) this.e;
        if (i4 == 0) {
            do {
                ((S) interfaceC0210v).add(Long.valueOf(dVar.v()));
                if (dVar.g()) {
                    return;
                } else {
                    iC = dVar.C();
                }
            } while (iC == this.f2994b);
            this.f2996d = iC;
            return;
        }
        if (i4 != 2) {
            throw C0213y.b();
        }
        int iF = dVar.f() + dVar.D();
        do {
            ((S) interfaceC0210v).add(Long.valueOf(dVar.v()));
        } while (dVar.f() < iF);
        O(iF);
    }

    public void z(List list) throws C0213y, com.google.crypto.tink.shaded.protobuf.B {
        int iC;
        int iC2;
        boolean z4 = list instanceof com.google.crypto.tink.shaded.protobuf.I;
        T0.d dVar = (T0.d) this.e;
        if (!z4) {
            int i4 = this.f2994b & 7;
            if (i4 == 0) {
                do {
                    list.add(Long.valueOf(dVar.v()));
                    if (dVar.g()) {
                        return;
                    } else {
                        iC = dVar.C();
                    }
                } while (iC == this.f2994b);
                this.f2996d = iC;
                return;
            }
            if (i4 != 2) {
                throw com.google.crypto.tink.shaded.protobuf.B.c();
            }
            int iF = dVar.f() + dVar.D();
            do {
                list.add(Long.valueOf(dVar.v()));
            } while (dVar.f() < iF);
            O(iF);
            return;
        }
        com.google.crypto.tink.shaded.protobuf.I i5 = (com.google.crypto.tink.shaded.protobuf.I) list;
        int i6 = this.f2994b & 7;
        if (i6 == 0) {
            do {
                i5.g(dVar.v());
                if (dVar.g()) {
                    return;
                } else {
                    iC2 = dVar.C();
                }
            } while (iC2 == this.f2994b);
            this.f2996d = iC2;
            return;
        }
        if (i6 != 2) {
            throw com.google.crypto.tink.shaded.protobuf.B.c();
        }
        int iF2 = dVar.f() + dVar.D();
        do {
            i5.g(dVar.v());
        } while (dVar.f() < iF2);
        O(iF2);
    }

    public C0199j(T0.d dVar, byte b5) {
        AbstractC0320z.a(dVar, "input");
        this.e = dVar;
        dVar.f1873b = this;
    }
}
