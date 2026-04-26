package n3;

import java.nio.channels.Selector;

/* JADX INFO: renamed from: n3.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0568d extends A3.c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public Selector f5902a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public /* synthetic */ Object f5903b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ e f5904c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public int f5905d;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0568d(e eVar, A3.c cVar) {
        super(cVar);
        this.f5904c = eVar;
    }

    @Override // A3.a
    public final Object invokeSuspend(Object obj) {
        this.f5903b = obj;
        this.f5905d |= Integer.MIN_VALUE;
        return this.f5904c.o(null, this);
    }
}
