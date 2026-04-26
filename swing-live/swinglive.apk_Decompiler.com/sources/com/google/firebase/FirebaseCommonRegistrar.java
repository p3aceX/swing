package com.google.firebase;

import A.C0003c;
import D2.u;
import android.content.Context;
import android.os.Build;
import com.google.firebase.components.ComponentRegistrar;
import e1.AbstractC0367g;
import h1.InterfaceC0411a;
import io.flutter.plugin.platform.f;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.concurrent.Executor;
import l1.C0522a;
import l1.j;
import l1.r;
import p1.c;
import p1.d;
import p1.e;
import u1.C0688a;
import u1.C0689b;
import w3.b;

/* JADX INFO: loaded from: classes.dex */
public class FirebaseCommonRegistrar implements ComponentRegistrar {
    public static String a(String str) {
        return str.replace(' ', '_').replace('/', '_');
    }

    @Override // com.google.firebase.components.ComponentRegistrar
    public final List getComponents() {
        String str;
        ArrayList arrayList = new ArrayList();
        HashSet hashSet = new HashSet();
        HashSet hashSet2 = new HashSet();
        HashSet hashSet3 = new HashSet();
        hashSet.add(r.a(C0689b.class));
        for (Class cls : new Class[0]) {
            AbstractC0367g.a(cls, "Null interface");
            hashSet.add(r.a(cls));
        }
        j jVar = new j(C0688a.class, 2, 0);
        if (hashSet.contains(jVar.f5611a)) {
            throw new IllegalArgumentException("Components are not allowed to depend on interfaces they themselves provide.");
        }
        hashSet2.add(jVar);
        arrayList.add(new C0522a(new HashSet(hashSet), new HashSet(hashSet2), 0, new C0003c(24), hashSet3));
        r rVar = new r(InterfaceC0411a.class, Executor.class);
        f fVar = new f(c.class, new Class[]{e.class, p1.f.class});
        fVar.a(new j(Context.class, 1, 0));
        fVar.a(new j(g1.f.class, 1, 0));
        fVar.a(new j(d.class, 2, 0));
        fVar.a(new j(C0689b.class, 1, 1));
        fVar.a(new j(rVar, 1, 0));
        fVar.f4629d = new u(rVar, 13);
        arrayList.add(fVar.b());
        arrayList.add(AbstractC0367g.g("fire-android", String.valueOf(Build.VERSION.SDK_INT)));
        arrayList.add(AbstractC0367g.g("fire-core", "20.4.2"));
        arrayList.add(AbstractC0367g.g("device-name", a(Build.PRODUCT)));
        arrayList.add(AbstractC0367g.g("device-model", a(Build.DEVICE)));
        arrayList.add(AbstractC0367g.g("device-brand", a(Build.BRAND)));
        arrayList.add(AbstractC0367g.t("android-target-sdk", new C0003c(14)));
        arrayList.add(AbstractC0367g.t("android-min-sdk", new C0003c(15)));
        arrayList.add(AbstractC0367g.t("android-platform", new C0003c(16)));
        arrayList.add(AbstractC0367g.t("android-installer", new C0003c(17)));
        try {
            b.f6716b.getClass();
            str = "2.2.21";
        } catch (NoClassDefFoundError unused) {
            str = null;
        }
        if (str != null) {
            arrayList.add(AbstractC0367g.g("kotlin", str));
        }
        return arrayList;
    }
}
