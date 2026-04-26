package p1;

import D2.v;
import K.k;
import N2.j;
import O2.m;
import O2.r;
import T2.J;
import android.os.SystemClock;
import android.text.TextUtils;
import android.util.Log;
import androidx.preference.EditTextPreference;
import androidx.preference.ListPreference;
import androidx.preference.Preference;
import com.google.android.gms.dynamite.descriptors.com.google.firebase.auth.ModuleDescriptor;
import com.swing.live.R;
import java.io.Serializable;
import java.util.HashMap;
import y0.C0747k;

/* JADX INFO: loaded from: classes.dex */
public final class d implements m, J, V.e {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static d f6185b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static d f6186c;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f6187a;

    public /* synthetic */ d(int i4) {
        this.f6187a = i4;
    }

    public CharSequence d(Preference preference) {
        switch (this.f6187a) {
            case 18:
                EditTextPreference editTextPreference = (EditTextPreference) preference;
                editTextPreference.getClass();
                if (TextUtils.isEmpty(null)) {
                    return editTextPreference.f3110a.getString(R.string.not_set);
                }
                return null;
            default:
                ListPreference listPreference = (ListPreference) preference;
                listPreference.getClass();
                if (TextUtils.isEmpty(null)) {
                    return listPreference.f3110a.getString(R.string.not_set);
                }
                return null;
        }
    }

    @Override // V.e
    public void f(int i4, Serializable serializable) {
        String str;
        switch (this.f6187a) {
            case 21:
                break;
            default:
                switch (i4) {
                    case 1:
                        str = "RESULT_INSTALL_SUCCESS";
                        break;
                    case 2:
                        str = "RESULT_ALREADY_INSTALLED";
                        break;
                    case 3:
                        str = "RESULT_UNSUPPORTED_ART_VERSION";
                        break;
                    case 4:
                        str = "RESULT_NOT_WRITABLE";
                        break;
                    case 5:
                        str = "RESULT_DESIRED_FORMAT_UNSUPPORTED";
                        break;
                    case k.STRING_SET_FIELD_NUMBER /* 6 */:
                        str = "RESULT_BASELINE_PROFILE_NOT_FOUND";
                        break;
                    case k.DOUBLE_FIELD_NUMBER /* 7 */:
                        str = "RESULT_IO_EXCEPTION";
                        break;
                    case k.BYTES_FIELD_NUMBER /* 8 */:
                        str = "RESULT_PARSE_EXCEPTION";
                        break;
                    case 9:
                    default:
                        str = "";
                        break;
                    case 10:
                        str = "RESULT_INSTALL_SKIP_FILE_SUCCESS";
                        break;
                    case ModuleDescriptor.MODULE_VERSION /* 11 */:
                        str = "RESULT_DELETE_SKIP_FILE_SUCCESS";
                        break;
                }
                if (i4 == 6 || i4 == 7 || i4 == 8) {
                    Log.e("ProfileInstaller", str, (Throwable) serializable);
                } else {
                    Log.d("ProfileInstaller", str);
                }
                break;
        }
    }

    @Override // O2.m
    public void g(v vVar, j jVar) {
        switch (this.f6187a) {
            case 10:
                jVar.c(null);
                break;
            default:
                jVar.c(null);
                break;
        }
    }

    @Override // V.e
    public void j() {
        switch (this.f6187a) {
            case 21:
                break;
            default:
                Log.d("ProfileInstaller", "DIAGNOSTIC_PROFILE_IS_COMPRESSED");
                break;
        }
    }

    public /* synthetic */ d(Object obj, int i4) {
        this.f6187a = i4;
    }

    public d() {
        this.f6187a = 9;
        SystemClock.elapsedRealtime();
    }

    public d(F2.b bVar) {
        this.f6187a = 11;
        new C0747k(bVar, "flutter/deferredcomponent", r.f1458a, 11).Y(new B.k(this, 6));
        C0747k.N().getClass();
        new HashMap();
    }

    private final void b() {
    }

    @Override // T2.J
    public void a(T2.v vVar) {
    }

    private final void c(int i4, Serializable serializable) {
    }
}
