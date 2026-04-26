package o3;

import java.security.cert.Certificate;

/* JADX INFO: renamed from: o3.s, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0610s extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public EnumC0604l f6140a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Certificate f6141b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public X.N f6142c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public C0597e f6143d;
    public byte[] e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public /* synthetic */ Object f6144f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final /* synthetic */ C0588D f6145m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public int f6146n;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0610s(C0588D c0588d, A3.c cVar) {
        super(cVar);
        this.f6145m = c0588d;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6144f = obj;
        this.f6146n |= Integer.MIN_VALUE;
        return this.f6145m.d(null, null, null, null, this);
    }
}
