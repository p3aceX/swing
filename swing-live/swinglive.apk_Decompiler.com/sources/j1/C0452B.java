package j1;

import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.internal.p002firebaseauthapi.zzaag;
import com.google.android.gms.tasks.Task;
import com.google.firebase.auth.FirebaseAuth;

/* JADX INFO: renamed from: j1.B, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0452B extends e1.k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ boolean f5160a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ l f5161b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ C0459d f5162c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final /* synthetic */ FirebaseAuth f5163d;

    public C0452B(FirebaseAuth firebaseAuth, boolean z4, l lVar, C0459d c0459d) {
        this.f5160a = z4;
        this.f5161b = lVar;
        this.f5162c = c0459d;
        this.f5163d = firebaseAuth;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r7v0, types: [j1.f, k1.p] */
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
    @Override // e1.k
    public final Task R(String str) {
        if (TextUtils.isEmpty(str)) {
            Log.i("FirebaseAuth", "Email link login/reauth with empty reCAPTCHA token");
        } else {
            Log.i("FirebaseAuth", "Got reCAPTCHA token for login/reauth with email link");
        }
        C0459d c0459d = this.f5162c;
        boolean z4 = this.f5160a;
        FirebaseAuth firebaseAuth = this.f5163d;
        if (!z4) {
            return firebaseAuth.e.zza(firebaseAuth.f3841a, c0459d, str, (k1.s) new C0462g(firebaseAuth));
        }
        zzaag zzaagVar = firebaseAuth.e;
        l lVar = this.f5161b;
        com.google.android.gms.common.internal.F.g(lVar);
        return zzaagVar.zzb(firebaseAuth.f3841a, lVar, c0459d, str, (k1.p) new C0461f(firebaseAuth, 0));
    }
}
