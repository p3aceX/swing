package com.google.firebase.auth;

import D2.u;
import R0.k;
import androidx.annotation.Keep;
import com.google.firebase.components.ComponentRegistrar;
import e1.AbstractC0367g;
import g1.f;
import h1.InterfaceC0411a;
import h1.c;
import i1.a;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.ScheduledExecutorService;
import k1.InterfaceC0510a;
import k1.d;
import l1.C0522a;
import l1.b;
import l1.j;
import l1.r;
import p1.e;
import q1.InterfaceC0634a;

/* JADX INFO: loaded from: classes.dex */
@Keep
public class FirebaseAuthRegistrar implements ComponentRegistrar {
    public static FirebaseAuth lambda$getComponents$0(r rVar, r rVar2, r rVar3, r rVar4, r rVar5, b bVar) {
        f fVar = (f) bVar.a(f.class);
        InterfaceC0634a interfaceC0634aC = bVar.c(a.class);
        InterfaceC0634a interfaceC0634aC2 = bVar.c(e.class);
        Executor executor = (Executor) bVar.b(rVar2);
        return new d(fVar, interfaceC0634aC, interfaceC0634aC2, executor, (ScheduledExecutorService) bVar.b(rVar4), (Executor) bVar.b(rVar5));
    }

    @Override // com.google.firebase.components.ComponentRegistrar
    @Keep
    public List<C0522a> getComponents() {
        r rVar = new r(InterfaceC0411a.class, Executor.class);
        r rVar2 = new r(h1.b.class, Executor.class);
        r rVar3 = new r(c.class, Executor.class);
        r rVar4 = new r(c.class, ScheduledExecutorService.class);
        r rVar5 = new r(h1.d.class, Executor.class);
        io.flutter.plugin.platform.f fVar = new io.flutter.plugin.platform.f(FirebaseAuth.class, new Class[]{InterfaceC0510a.class});
        fVar.a(new j(f.class, 1, 0));
        fVar.a(new j(e.class, 1, 1));
        fVar.a(new j(rVar, 1, 0));
        fVar.a(new j(rVar2, 1, 0));
        fVar.a(new j(rVar3, 1, 0));
        fVar.a(new j(rVar4, 1, 0));
        fVar.a(new j(rVar5, 1, 0));
        fVar.a(new j(a.class, 0, 1));
        k kVar = new k(2);
        kVar.f1691b = rVar;
        kVar.f1692c = rVar2;
        kVar.f1693d = rVar3;
        kVar.e = rVar4;
        kVar.f1694f = rVar5;
        fVar.f4629d = kVar;
        C0522a c0522aB = fVar.b();
        p1.d dVar = new p1.d(0);
        HashSet hashSet = new HashSet();
        HashSet hashSet2 = new HashSet();
        HashSet hashSet3 = new HashSet();
        hashSet.add(r.a(p1.d.class));
        return Arrays.asList(c0522aB, new C0522a(new HashSet(hashSet), new HashSet(hashSet2), 1, new u(dVar, 11), hashSet3), AbstractC0367g.g("fire-auth", "22.3.1"));
    }
}
