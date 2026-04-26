package s0;

import android.os.Bundle;
import com.google.android.gms.common.api.e;
import com.google.android.gms.common.internal.F;
import java.util.Arrays;
import java.util.Set;

/* JADX INFO: renamed from: s0.c, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0662c implements e {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0662c f6473b = new C0662c(new Bundle());

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final Bundle f6474a;

    public /* synthetic */ C0662c(Bundle bundle) {
        this.f6474a = bundle;
    }

    public final boolean equals(Object obj) {
        if (obj == this) {
            return true;
        }
        if (!(obj instanceof C0662c)) {
            return false;
        }
        Bundle bundle = ((C0662c) obj).f6474a;
        Bundle bundle2 = this.f6474a;
        if (bundle2 == null || bundle == null) {
            return bundle2 == bundle;
        }
        if (bundle2.size() == bundle.size()) {
            Set<String> setKeySet = bundle2.keySet();
            if (setKeySet.containsAll(bundle.keySet())) {
                for (String str : setKeySet) {
                    if (!F.j(bundle2.get(str), bundle.get(str))) {
                    }
                }
            }
        }
    }

    public final int hashCode() {
        return Arrays.hashCode(new Object[]{this.f6474a});
    }
}
