package Y0;

import I.C0053n;
import d1.X;
import f1.C0400a;
import java.security.GeneralSecurityException;
import java.util.HashMap;
import java.util.concurrent.atomic.AtomicReference;

/* JADX INFO: loaded from: classes.dex */
public final class h {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final h f2478b = new h();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final AtomicReference f2479a = new AtomicReference(new r(new C0053n(7)));

    public final R0.b a(n nVar) {
        AtomicReference atomicReference = this.f2479a;
        r rVar = (r) atomicReference.get();
        rVar.getClass();
        C0400a c0400a = (C0400a) nVar.f2489b;
        if (!rVar.f2499b.containsKey(new p(n.class, c0400a))) {
            try {
                W0.a aVar = new W0.a();
                ((X) nVar.f2491d).ordinal();
                return aVar;
            } catch (GeneralSecurityException e) {
                throw new A0.b("Creating a LegacyProtoKey failed", e);
            }
        }
        r rVar2 = (r) atomicReference.get();
        rVar2.getClass();
        p pVar = new p(n.class, c0400a);
        HashMap map = rVar2.f2499b;
        if (map.containsKey(pVar)) {
            return ((a) map.get(pVar)).f2466b.d(nVar);
        }
        throw new GeneralSecurityException("No Key Parser for requested key type " + pVar + " available");
    }

    public final synchronized void b(a aVar) {
        C0053n c0053n = new C0053n((r) this.f2479a.get());
        c0053n.r(aVar);
        this.f2479a.set(new r(c0053n));
    }

    public final synchronized void c(b bVar) {
        C0053n c0053n = new C0053n((r) this.f2479a.get());
        c0053n.s(bVar);
        this.f2479a.set(new r(c0053n));
    }

    public final synchronized void d(i iVar) {
        C0053n c0053n = new C0053n((r) this.f2479a.get());
        c0053n.t(iVar);
        this.f2479a.set(new r(c0053n));
    }

    public final synchronized void e(j jVar) {
        C0053n c0053n = new C0053n((r) this.f2479a.get());
        c0053n.u(jVar);
        this.f2479a.set(new r(c0053n));
    }
}
