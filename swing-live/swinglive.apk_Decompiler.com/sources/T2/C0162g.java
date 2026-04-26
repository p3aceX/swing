package T2;

import k.s0;

/* JADX INFO: renamed from: T2.g, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class C0162g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ s0 f1964a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ t f1965b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ String f1966c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ F f1967d;

    public /* synthetic */ C0162g(s0 s0Var, t tVar, String str, F f4) {
        this.f1964a = s0Var;
        this.f1965b = tVar;
        this.f1966c = str;
        this.f1967d = f4;
    }

    public final void a(String str, String str2) {
        String str3 = this.f1966c;
        F f4 = this.f1967d;
        s0 s0Var = this.f1964a;
        s0Var.getClass();
        t tVar = this.f1965b;
        if (str != null) {
            tVar.a(new v(null, str, str2));
            return;
        }
        try {
            tVar.d(s0Var.i(str3, f4));
        } catch (Exception e) {
            s0.f(e, tVar);
        }
    }
}
