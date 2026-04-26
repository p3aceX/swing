package D1;

/* JADX INFO: loaded from: classes.dex */
public final class b extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public byte[] f145a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f146b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ a f147c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f148d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public b(a aVar, A3.c cVar) {
        super(cVar);
        this.f147c = aVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f146b = obj;
        this.f148d |= Integer.MIN_VALUE;
        return a.k(this.f147c, 0, this);
    }
}
