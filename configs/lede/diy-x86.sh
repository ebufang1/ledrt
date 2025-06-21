#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-Selfuse.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
sed -i 's/192.168.1.1/192.168.1.2/g' package/base-files/files/bin/config_generate

# Hostname
sed -i 's/LEDE/fang/g' package/base-files/files/bin/config_generate

sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/arm/index.htm

# Timezone
#sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate

# cpufreq
#sed -i 's/LUCI_DEPENDS.*/LUCI_DEPENDS:=\@\(arm\|\|aarch64\)/g' package/lean/luci-app-cpufreq/Makefile
#sed -i 's/services/system/g' package/lean/luci-app-cpufreq/luasrc/controller/cpufreq.lua

# Change default theme
sed -i 's#luci-theme-bootstrap#luci-theme-opentomcat#g' feeds/luci/collections/luci/Makefile
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

# Add additional packages
function merge_package() {
    # 参数1是分支名,参数2是库地址,参数3是所有文件下载到指定路径。
    # 同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开。
    if [[ $# -lt 3 ]]; then
        echo "Syntax error: [$#] [$*]" >&2
        return 1
    fi
    trap 'rm -rf "$tmpdir"' EXIT
    branch="$1" curl="$2" target_dir="$3" && shift 3
    rootdir="$PWD"
    localdir="$target_dir"
    [ -d "$localdir" ] || mkdir -p "$localdir"
    tmpdir="$(mktemp -d)" || exit 1
    git clone -b "$branch" --depth 1 --filter=blob:none --sparse "$curl" "$tmpdir"
    cd "$tmpdir"
    git sparse-checkout init --cone
    git sparse-checkout set "$@"
    # 使用循环逐个移动文件夹
    for folder in "$@"; do
        mv -f "$folder" "$rootdir/$localdir"
    done
    cd "$rootdir"
}
merge_package master https://github.com/fw876/helloworld package/fang dns2socks-rust

rm -rf feeds/luci/applications/luci-app-mosdns
rm -rf feeds/packages/net/{alist,adguardhome,mosdns,xray*,v2ray*,v2ray*,sing*,smartdns}
rm -rf feeds/packages/utils/v2dat
rm -rf feeds/packages/lang/golang
git clone https://github.com/kenzok8/golang -b 1.23 feeds/packages/lang/golang
sed -i 's|^PKG_VERSION.*|PKG_VERSION:=25.2.21|' feeds/small/xray-core/Makefile
sed -i 's|^PKG_HASH.*|PKG_HASH:=a565db518d2da12fabb74e123d9bf2bdbc34420b81373938f8fcbc7004fda3ba|' feeds/small/xray-core/Makefile
git clone --depth=1 https://github.com/Leo-Jo-My/luci-theme-opentomcat.git package/luci-theme-opentomcat
sed -i 's|^KERNEL_PATCHVER:=6.6|KERNEL_PATCHVER:=6.1|' target/linux/x86/Makefile

# Delete mosdns
#rm -rf feeds/packages/net/mosdns

# Update Go Version
#rm -rf feeds/packages/lang/golang && git clone -b 22.x https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang

# dockerd去版本验证
#sed -i 's/^\s*$[(]call\sEnsureVendoredVersion/#&/' feeds/packages/utils/dockerd/Makefile

sed -i '750a\
                <tr><td width="33%">&#32534;&#35793;&#32773;&#58;&#32;&#83;&#105;&#108;</td><td><a href="https://t.me/passwall2" style="color: black;" target="_blank">&#32676;&#32452;&#38142;&#25509;</a></td></tr>\
                <tr><td width="33%">&#28304;&#30721;&#58;&#32;&#108;&#101;&#100;&#101;</td><td><a href="https://github.com/coolsnowwolf/lede" style="color: black;" target="_blank">&#28304;&#30721;&#38142;&#25509;</a></td></tr>
' package/lean/autocore/files/x86/index.htm
