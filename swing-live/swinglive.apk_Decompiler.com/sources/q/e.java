package q;

import D2.AbstractActivityC0029d;
import android.app.Activity;
import android.os.Build;
import android.text.TextUtils;
import com.google.crypto.tink.shaded.protobuf.S;
import java.util.Arrays;
import java.util.HashSet;

/* JADX INFO: loaded from: classes.dex */
public abstract class e extends r.h {
    /* JADX WARN: Multi-variable type inference failed */
    public static void a(Activity activity, String[] strArr, int i4) {
        HashSet hashSet = new HashSet();
        for (int i5 = 0; i5 < strArr.length; i5++) {
            if (TextUtils.isEmpty(strArr[i5])) {
                throw new IllegalArgumentException(S.h(new StringBuilder("Permission request for permissions "), Arrays.toString(strArr), " must not contain null or empty values"));
            }
            if (Build.VERSION.SDK_INT < 33 && TextUtils.equals(strArr[i5], "android.permission.POST_NOTIFICATIONS")) {
                hashSet.add(Integer.valueOf(i5));
            }
        }
        int size = hashSet.size();
        String[] strArr2 = size > 0 ? new String[strArr.length - size] : strArr;
        if (size > 0) {
            if (size == strArr.length) {
                return;
            }
            int i6 = 0;
            for (int i7 = 0; i7 < strArr.length; i7++) {
                if (!hashSet.contains(Integer.valueOf(i7))) {
                    strArr2[i6] = strArr[i7];
                    i6++;
                }
            }
        }
        if (activity instanceof d) {
            ((d) activity).getClass();
        }
        AbstractC0624a.b(activity, strArr, i4);
    }

    public static boolean b(AbstractActivityC0029d abstractActivityC0029d, String str) {
        int i4 = Build.VERSION.SDK_INT;
        if (i4 >= 33 || !TextUtils.equals("android.permission.POST_NOTIFICATIONS", str)) {
            return i4 >= 32 ? AbstractC0626c.a(abstractActivityC0029d, str) : i4 == 31 ? AbstractC0625b.b(abstractActivityC0029d, str) : AbstractC0624a.c(abstractActivityC0029d, str);
        }
        return false;
    }
}
