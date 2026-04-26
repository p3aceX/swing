package n3;

/* JADX INFO: renamed from: n3.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0567c extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public m f5898a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f5899b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ e f5900c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5901d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0567c(e eVar, A3.c cVar) {
        super(cVar);
        this.f5900c = eVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5899b = obj;
        this.f5901d |= Integer.MIN_VALUE;
        return this.f5900c.l(null, this);
    }
}
