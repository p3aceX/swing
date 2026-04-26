package E1;

/* JADX INFO: loaded from: classes.dex */
public final class e extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public byte[] f323a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f324b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ b f325c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f326d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public e(b bVar, A3.c cVar) {
        super(cVar);
        this.f325c = bVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f324b = obj;
        this.f326d |= Integer.MIN_VALUE;
        return b.n(this.f325c, 0, this);
    }
}
