package r2;

/* JADX INFO: loaded from: classes.dex */
public final class c extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f6319a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public Y3.d f6320b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f6321c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ i f6322d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public c(i iVar, A3.c cVar) {
        super(cVar);
        this.f6322d = iVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f6321c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f6322d.c(0, this);
    }
}
