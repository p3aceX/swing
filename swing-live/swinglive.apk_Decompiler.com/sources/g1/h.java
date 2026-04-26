package g1;

import com.google.android.gms.common.internal.F;

/* JADX INFO: loaded from: classes.dex */
public class h extends Exception {
    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public h(String str) {
        super(str);
        F.e(str, "Detail message must not be empty");
    }
}
