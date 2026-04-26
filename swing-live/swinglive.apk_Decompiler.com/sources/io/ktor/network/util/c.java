package io.ktor.network.util;

import A3.j;
import I3.l;
import J3.i;
import Q3.C;
import Q3.D;
import Q3.F;
import Q3.y0;

/* JADX INFO: loaded from: classes.dex */
public final class c {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final long f4948a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final I3.a f4949b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final j f4950c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final y0 f4951d;
    volatile /* synthetic */ int isStarted;
    volatile /* synthetic */ long lastActivityTime;

    /* JADX WARN: Multi-variable type inference failed */
    public c(String str, long j4, I3.a aVar, D d5, l lVar) {
        i.e(d5, "scope");
        this.f4948a = j4;
        this.f4949b = aVar;
        this.f4950c = (j) lVar;
        this.lastActivityTime = 0L;
        this.isStarted = 0;
        this.f4951d = j4 != Long.MAX_VALUE ? F.s(d5, d5.n().s(new C("Timeout ".concat(str))), new b(this, null), 2) : null;
    }

    public final void a() {
        this.lastActivityTime = ((Number) this.f4949b.a()).longValue();
        this.isStarted = 1;
    }

    public final void b() {
        this.isStarted = 0;
    }
}
