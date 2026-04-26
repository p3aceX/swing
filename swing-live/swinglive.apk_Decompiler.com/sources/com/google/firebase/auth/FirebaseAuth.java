package com.google.firebase.auth;

import R0.k;
import android.content.SharedPreferences;
import android.util.Log;
import androidx.annotation.Keep;
import com.google.android.gms.common.internal.F;
import com.google.android.gms.common.internal.r;
import com.google.android.gms.internal.p002firebaseauthapi.zzaag;
import com.google.android.recaptcha.RecaptchaAction;
import g1.f;
import j1.G;
import j1.l;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Executor;
import k1.InterfaceC0510a;
import k1.e;
import k1.h;
import k1.q;
import q1.InterfaceC0634a;
import r1.a;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public class FirebaseAuth implements InterfaceC0510a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final f f3841a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final CopyOnWriteArrayList f3842b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final CopyOnWriteArrayList f3843c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final CopyOnWriteArrayList f3844d;
    public final zzaag e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public l f3845f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final Object f3846g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public final Object f3847h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public final String f3848i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public k f3849j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public final RecaptchaAction f3850k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public final RecaptchaAction f3851l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final RecaptchaAction f3852m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final r f3853n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public final q f3854o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public final InterfaceC0634a f3855p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public final InterfaceC0634a f3856q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public C0779j f3857r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public final Executor f3858s;

    /* JADX INFO: renamed from: t, reason: collision with root package name */
    public final Executor f3859t;

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Removed duplicated region for block: B:4:0x00b7  */
    /* JADX WARN: Type inference failed for: r3v11, types: [j1.f, k1.p] */
    /* JADX WARN: Type inference failed for: r5v2, types: [j1.f, k1.p] */
    /* JADX WARN: Type inference failed for: r5v3, types: [j1.f, k1.p] */
    /* JADX WARN: Type inference fix 'apply assigned field type' failed
    java.lang.UnsupportedOperationException: ArgType.getObject(), call class: class jadx.core.dex.instructions.args.ArgType$UnknownArg
    	at jadx.core.dex.instructions.args.ArgType.getObject(ArgType.java:593)
    	at jadx.core.dex.attributes.nodes.ClassTypeVarsAttr.getTypeVarsMapFor(ClassTypeVarsAttr.java:35)
    	at jadx.core.dex.nodes.utils.TypeUtils.replaceClassGenerics(TypeUtils.java:177)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.insertExplicitUseCast(FixTypesVisitor.java:397)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.tryFieldTypeWithNewCasts(FixTypesVisitor.java:359)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.applyFieldType(FixTypesVisitor.java:309)
    	at jadx.core.dex.visitors.typeinference.FixTypesVisitor.visit(FixTypesVisitor.java:94)
     */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public FirebaseAuth(g1.f r13, q1.InterfaceC0634a r14, q1.InterfaceC0634a r15, java.util.concurrent.Executor r16, java.util.concurrent.ScheduledExecutorService r17, java.util.concurrent.Executor r18) {
        /*
            Method dump skipped, instruction units count: 928
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.firebase.auth.FirebaseAuth.<init>(g1.f, q1.a, q1.a, java.util.concurrent.Executor, java.util.concurrent.ScheduledExecutorService, java.util.concurrent.Executor):void");
    }

    public static void b(FirebaseAuth firebaseAuth, l lVar) {
        if (lVar != null) {
            Log.d("FirebaseAuth", "Notifying auth state listeners about user ( " + ((e) lVar).f5513b.f5505a + " ).");
        } else {
            Log.d("FirebaseAuth", "Notifying auth state listeners about a sign-out event.");
        }
        firebaseAuth.f3859t.execute(new G(firebaseAuth));
    }

    /* JADX WARN: Removed duplicated region for block: B:42:0x00ba  */
    /*
        Code decompiled incorrectly, please refer to instructions dump.
        To view partially-correct code enable 'Show inconsistent code' option in preferences
    */
    public static void c(com.google.firebase.auth.FirebaseAuth r18, j1.l r19, com.google.android.gms.internal.p002firebaseauthapi.zzafm r20, boolean r21, boolean r22) {
        /*
            Method dump skipped, instruction units count: 821
            To view this dump change 'Code comments level' option to 'DEBUG'
        */
        throw new UnsupportedOperationException("Method not decompiled: com.google.firebase.auth.FirebaseAuth.c(com.google.firebase.auth.FirebaseAuth, j1.l, com.google.android.gms.internal.firebase-auth-api.zzafm, boolean, boolean):void");
    }

    public static void d(FirebaseAuth firebaseAuth, l lVar) {
        if (lVar != null) {
            Log.d("FirebaseAuth", "Notifying id token listeners about user ( " + ((e) lVar).f5513b.f5505a + " ).");
        } else {
            Log.d("FirebaseAuth", "Notifying id token listeners about a sign-out event.");
        }
        String strZzc = lVar != null ? ((e) lVar).f5512a.zzc() : null;
        a aVar = new a();
        aVar.f6306a = strZzc;
        firebaseAuth.f3859t.execute(new G(firebaseAuth, aVar));
    }

    @Keep
    public static FirebaseAuth getInstance() {
        f fVarC = f.c();
        fVarC.a();
        return (FirebaseAuth) fVarC.f4310d.a(FirebaseAuth.class);
    }

    public final void a() {
        r rVar = this.f3853n;
        F.g(rVar);
        l lVar = this.f3845f;
        if (lVar != null) {
            ((SharedPreferences) rVar.f3597b).edit().remove(B1.a.m("com.google.firebase.auth.GET_TOKEN_RESPONSE.", ((e) lVar).f5513b.f5505a)).apply();
            this.f3845f = null;
        }
        ((SharedPreferences) rVar.f3597b).edit().remove("com.google.firebase.auth.FIREBASE_USER").apply();
        d(this, null);
        b(this, null);
        C0779j c0779j = this.f3857r;
        if (c0779j != null) {
            h hVar = (h) c0779j.f6969b;
            hVar.f5532c.removeCallbacks(hVar.f5533d);
        }
    }

    @Keep
    public static FirebaseAuth getInstance(f fVar) {
        fVar.a();
        return (FirebaseAuth) fVar.f4310d.a(FirebaseAuth.class);
    }
}
