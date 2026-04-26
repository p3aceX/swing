package j1;

import com.google.firebase.auth.FirebaseAuth;
import java.util.Iterator;

/* JADX INFO: loaded from: classes.dex */
public final class G implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f5179a = 0;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ FirebaseAuth f5180b;

    public G(FirebaseAuth firebaseAuth) {
        this.f5180b = firebaseAuth;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f5179a) {
            case 0:
                Iterator it = this.f5180b.f3844d.iterator();
                if (it.hasNext()) {
                    it.next().getClass();
                    throw new ClassCastException();
                }
                return;
            default:
                FirebaseAuth firebaseAuth = this.f5180b;
                Iterator it2 = firebaseAuth.f3843c.iterator();
                if (it2.hasNext()) {
                    it2.next().getClass();
                    throw new ClassCastException();
                }
                Iterator it3 = firebaseAuth.f3842b.iterator();
                if (it3.hasNext()) {
                    it3.next().getClass();
                    throw new ClassCastException();
                }
                return;
        }
    }

    public G(FirebaseAuth firebaseAuth, r1.a aVar) {
        this.f5180b = firebaseAuth;
    }
}
