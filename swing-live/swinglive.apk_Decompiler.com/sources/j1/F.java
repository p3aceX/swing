package j1;

import android.text.TextUtils;
import android.util.Log;
import com.google.android.gms.tasks.Task;

/* JADX INFO: loaded from: classes.dex */
public final class F extends e1.k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ l f5176a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0459d f5177b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final /* synthetic */ k1.d f5178c;

    public F(k1.d dVar, l lVar, C0459d c0459d) {
        this.f5176a = lVar;
        this.f5177b = c0459d;
        this.f5178c = dVar;
    }

    /* JADX WARN: Multi-variable type inference failed */
    /* JADX WARN: Type inference failed for: r6v0, types: [j1.f, k1.p] */
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
            Log.i("FirebaseAuth", "Linking email account with empty reCAPTCHA token");
        } else {
            Log.i("FirebaseAuth", "Got reCAPTCHA token for linking email account");
        }
        k1.d dVar = this.f5178c;
        ?? c0461f = new C0461f(dVar, 0);
        return dVar.e.zza(dVar.f3841a, this.f5176a, (AbstractC0458c) this.f5177b, str, (k1.p) c0461f);
    }
}
