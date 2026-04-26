package g2;

import e1.AbstractC0367g;

/* JADX INFO: loaded from: classes.dex */
public final class i extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public f f4366a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public AbstractC0367g f4367b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public /* synthetic */ Object f4368c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ j f4369d;
    public int e;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public i(j jVar, A3.c cVar) {
        super(cVar);
        this.f4369d = jVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f4368c = obj;
        this.e |= Integer.MIN_VALUE;
        return this.f4369d.b(null, null, this);
    }
}
